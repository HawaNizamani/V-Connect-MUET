// ✅ Firebase Functions v2
const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
} = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// Helper: save notification
async function saveNotification(userId, title, body) {
  try {
    await db.collection("notifications").doc(userId).collection("userNotifications").add({
      title,
      body,
      createdAt: FieldValue.serverTimestamp(),
      read: false,
    });
    console.log(`📩 Notification saved for user: ${userId}`);
  } catch (err) {
    console.error(`❌ Error saving notification for ${userId}:`, err);
  }
}

// 1️⃣ Notify all students when an organization posts a new opportunity
exports.sendNotificationOnNewOpportunity = onDocumentCreated(
  "opportunities/{opportunityId}",
  async (event) => {
    try {
      const opportunity = event.data.data();
      const studentsSnapshot = await db
        .collection("users")
        .where("role", "==", "student")
        .get();

      const tokens = [];
      studentsSnapshot.forEach((doc) => {
        const token = doc.data().fcmToken;
        if (token) tokens.push(token);
      });

      // ✅ Send push notification to all student tokens
      if (tokens.length > 0) {
        await messaging.sendEachForMulticast({
          tokens,
          notification: {
            title: "New Opportunity Posted",
            body: opportunity.title || "Check out the new opportunity!",
          },
        });
      }

      // ✅ Save notifications for all students
      await Promise.all(
        studentsSnapshot.docs.map((doc) =>
          saveNotification(
            doc.id,
            "New Opportunity Posted",
            opportunity.title || "Check out the new opportunity!"
          )
        )
      );

      console.log("✅ Notifications sent and saved for all students.");
    } catch (err) {
      console.error("❌ Error in sendNotificationOnNewOpportunity:", err);
    }
  }
);

// 2️⃣ Notify organization when a student applies
exports.notifyOrganizationOnApply = onDocumentCreated(
  "applications/{appId}",
  async (event) => {
    try {
      const app = event.data.data();
      const orgId = app.orgId; // ⚠️ Ensure this field matches your Firestore

      if (!orgId) {
        console.warn("⚠️ No orgId found in application document.");
        return;
      }

      const orgDoc = await db.collection("users").doc(orgId).get();
      const token = orgDoc.data()?.fcmToken;

      if (token) {
        await messaging.send({
          token,
          notification: {
            title: "New Application Received",
            body: `A student applied for ${app.title || "your opportunity"}.`,
          },
        });
      }

      await saveNotification(
        orgId,
        "New Application Received",
        `A student applied for ${app.title || "your opportunity"}.`
      );
    } catch (err) {
      console.error("❌ Error in notifyOrganizationOnApply:", err);
    }
  }
);

// 3️⃣ Notify student when their application status changes
exports.notifyStudentOnDecision = onDocumentUpdated(
  "applications/{appId}",
  async (event) => {
    try {
      const before = event.data.before.data();
      const after = event.data.after.data();

      if (before.status !== after.status) {
        const studentId = after.uid; // ⚠️ Make sure this matches your Firestore user ID field

        const studentDoc = await db.collection("users").doc(studentId).get();
        const token = studentDoc.data()?.fcmToken;

        if (token) {
          await messaging.send({
            token,
            notification: {
              title: "Application Status Updated",
              body: `Your application has been ${after.status.toLowerCase()}.`,
            },
          });
        }

        await saveNotification(
          studentId,
          "Application Status Updated",
          `Your application has been ${after.status.toLowerCase()}.`
        );
      }
    } catch (err) {
      console.error("❌ Error in notifyStudentOnDecision:", err);
    }
  }
);

// 4️⃣ Auto-delete related applications when an opportunity is deleted
exports.cleanupApplicationsOnOpportunityDelete = onDocumentDeleted(
  "opportunities/{opportunityId}",
  async (event) => {
    try {
      const opportunityId = event.params.opportunityId;
      const appsSnapshot = await db
        .collection("applications")
        .where("opportunityId", "==", opportunityId)
        .get();

      if (appsSnapshot.empty) {
        console.log(`✅ No applications found for deleted opportunity: ${opportunityId}`);
        return;
      }

      const batch = db.batch();
      appsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();

      console.log(`🗑️ Deleted ${appsSnapshot.size} applications linked to opportunity: ${opportunityId}`);
    } catch (err) {
      console.error("❌ Error in cleanupApplicationsOnOpportunityDelete:", err);
    }
  }
);
