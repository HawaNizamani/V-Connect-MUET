import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'applications_screen.dart';
import 'applied_opportunities_screen.dart';
import 'available_opportunities_screen.dart';
import 'chatbot_screen.dart';
import 'profile_organization_screen.dart';
import 'profile_student_screen.dart';
import 'bottom_navbar_organization.dart';
import 'bottom_navbar_student.dart';
import 'dashboard_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedTab = 'ALL';
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _messaging.requestPermission();

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);
    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _showLocalNotification(notification);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  Future<String?> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }

  void _onNavTap(String role, int index) async {
    if (index == 3) return;

    if (role == 'organization') {
      switch (index) {
        case 0:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()));
          break;
        case 1:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ApplicationsScreen()));
          break;
        case 2:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()));
          break;
        case 4:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => ProfileOrganizationScreen()));
          break;
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AvailableOpportunitiesScreen()));
          break;
        case 1:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AppliedOpportunitiesScreen()));
          break;
        case 2:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()));
          break;
        case 4:
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();
            if (!mounted) return;
            final userData = doc.data();
            if (userData != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileStudentScreen(userData: userData),
                ),
              );
            }
          }
          break;
      }
    }
  }

  /// ✅ Updated: Now includes onTap navigation + marks as read
  Widget buildNotificationCard(Map<String, dynamic> notif, String role, String docId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return InkWell(
      onTap: () async {
        // ✅ Mark as read in Firestore
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(uid)
              .collection('userNotifications')
              .doc(docId)
              .update({'read': true});
        }

        // ✅ Navigate based on role
        if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AvailableOpportunitiesScreen()),
          );
        } else if (role == 'organization') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ApplicationsScreen()),
          );
        }
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: ListTile(
          leading: const Icon(Icons.notifications, color: Color(0xFF0A1D56)),
          title: Text(
            notif["title"] ?? "New Notification",
            style: TextStyle(
              fontWeight:
              (notif["read"] ?? false) ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Text(notif["body"] ?? "You have a new update."),
          trailing: Text(
            notif["createdAt"] != null
                ? TimeOfDay.fromDateTime(notif["createdAt"]).format(context)
                : "",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0A1D56);

    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, roleSnap) {
        if (roleSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!roleSnap.hasData || roleSnap.data == null) {
          return const Scaffold(
              body: Center(child: Text("No role found.")));
        }

        final role = roleSnap.data!;
        final uid = FirebaseAuth.instance.currentUser?.uid;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .doc(uid)
              .collection('userNotifications') // ✅ Correct subcollection
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, notifSnap) {
            if (notifSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            if (!notifSnap.hasData || notifSnap.data!.docs.isEmpty) {
              return Scaffold(
                body: const Center(child: Text("No notifications available.")),
                bottomNavigationBar: role == 'student'
                    ? StudentNavbar(
                  currentIndex: 3,
                  onTap: (index) => _onNavTap('student', index),
                )
                    : OrganizationNavbar(
                  currentIndex: 3,
                  onTap: (index) => _onNavTap('organization', index),
                ),
              );
            }

            final notifications = notifSnap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                "id": doc.id,
                "title": data["title"] ?? "New Notification",
                "body": data["body"] ?? "You have a new update.",
                "read": data["read"] ?? false,
                "createdAt": (data["createdAt"] as Timestamp?)?.toDate(),
              };
            }).toList();

            final filtered = selectedTab == 'UNREAD'
                ? notifications.where((n) => !(n["read"] ?? false)).toList()
                : notifications;

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: primary),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => selectedTab = 'ALL'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selectedTab == 'ALL'
                                    ? primary.withOpacity(0.15)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('All'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => setState(() => selectedTab = 'UNREAD'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selectedTab == 'UNREAD'
                                    ? primary.withOpacity(0.15)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Unread'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: filtered
                            .map((notif) => buildNotificationCard(
                            notif, role, notif["id"].toString()))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: role == 'student'
                  ? StudentNavbar(
                currentIndex: 3,
                onTap: (index) => _onNavTap('student', index),
              )
                  : OrganizationNavbar(
                currentIndex: 3,
                onTap: (index) => _onNavTap('organization', index),
              ),
            );
          },
        );
      },
    );
  }
}
