const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// 1. Notify students when an organization posts a new opportunity
exports.sendNotificationOnNewOpportunity = functions.firestore
  .document("opportunities/{opportunityId}")
  .onCreate(async (snap, context) => {
    const opportunity = snap.data();

    const studentsSnapshot = await admin.firestore().collection("users")
      .where("role", "==", "student").get();

    const tokens = [];
    studentsSnapshot.forEach(doc => {
      const token = doc.data().fcmToken;
      if (token) tokens.push(token);
    });

    const payload = {
      notification: {
        title: "New Opportunity Posted",
        body: opportunity.title || "Check out the new opportunity!",
      },
    };

    if (tokens.length > 0) {
      await admin.messaging().sendToDevice(tokens, payload);
    }
  });

// 2. Notify organization when a student applies
exports.notifyOrganizationOnApply = functions.firestore
  .document("applications/{appId}")
  .onCreate(async (snap, context) => {
    const app = snap.data();
    const orgId = app.organizationId;

    const orgDoc = await admin.firestore().collection("users").doc(orgId).get();
    const token = orgDoc.data().fcmToken;

    if (token) {
      const payload = {
        notification: {
          title: "New Application Received",
          body: `A student applied for ${app.opportunityTitle || "your opportunity"}.`,
        }
      };
      await admin.messaging().sendToDevice(token, payload);
    }
  });

// 3. Notify student when their application is accepted or rejected
exports.notifyStudentOnDecision = functions.firestore
  .document("applications/{appId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status !== after.status) {
      const studentId = after.studentId;

      const studentDoc = await admin.firestore().collection("users").doc(studentId).get();
      const token = studentDoc.data().fcmToken;

      if (token) {
        const payload = {
          notification: {
            title: "Application Status Updated",
            body: `Your application has been ${after.status.toLowerCase()}.`,
          }
        };
        await admin.messaging().sendToDevice(token, payload);
      }
    }
  });
