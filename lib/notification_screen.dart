import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/applications_screen.dart';
import 'package:v_connect_muet/applied_opportunities_screen.dart';
import 'package:v_connect_muet/available_opportunities_screen.dart';
import 'package:v_connect_muet/chatbot_screen.dart';
import 'package:v_connect_muet/profile_organization_screen.dart';
import 'package:v_connect_muet/profile_student_screen.dart';

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

  final List<Map<String, dynamic>> allNotifications = [
    {
      "title": "New Volunteer Request",
      "subtitle": "A student applied for your Blood Donation Drive.",
      "time": "1 hour ago",
      "date": "TODAY",
      "read": false,
    },
    {
      "title": "Event Reminder",
      "subtitle": "Tree Plantation drive tomorrow at 10 AM.",
      "time": "1 day ago",
      "date": "YESTERDAY",
      "read": true,
    },
    {
      "title": "Application Approved",
      "subtitle": "Student application for Beach Cleanup approved.",
      "time": "2 days ago",
      "date": "YESTERDAY",
      "read": false,
    },
  ];

  Future<String?> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role']; // assumes role is "student" or "organization"
  }

  void _onNavTap(String role, int index) async {
    if (index == 3) return; // already on notifications

    if (role == 'organization') {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ApplicationsScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfileOrganizationScreen()),
          );
          break;
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AvailableOpportunitiesScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AppliedOpportunitiesScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
          break;
        case 4:
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            final doc =
                await FirebaseFirestore.instance
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

  List<Map<String, dynamic>> getFilteredNotifications() {
    if (selectedTab == 'UNREAD') {
      return allNotifications.where((n) => !n['read']).toList();
    }
    return allNotifications;
  }

  Widget buildNotificationCard(Map<String, dynamic> notif) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          notif["title"],
          style: TextStyle(
            fontWeight: notif["read"] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(notif["subtitle"]),
        leading: const Icon(Icons.notifications),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Selected: $value")));
          },
          itemBuilder:
              (context) => const [
                PopupMenuItem(value: 'delete', child: Text('Delete')),
                PopupMenuItem(value: 'mute', child: Text('Mute')),
              ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0A1D56);
    final notifications = getFilteredNotifications();
    final today = notifications.where((n) => n['date'] == 'TODAY').toList();
    final yesterday =
        notifications.where((n) => n['date'] == 'YESTERDAY').toList();

    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Settings tapped")),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ALL / UNREAD toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => selectedTab = 'ALL'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedTab == 'ALL'
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
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedTab == 'UNREAD'
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

                // Notification List
                Expanded(
                  child:
                      notifications.isEmpty
                          ? const Center(
                            child: Text("No notifications available."),
                          )
                          : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              if (today.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 4),
                                  child: Text(
                                    'Today',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primary,
                                    ),
                                  ),
                                ),
                                ...today.map(buildNotificationCard),
                              ],
                              if (yesterday.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 4),
                                  child: Text(
                                    'Yesterday',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primary,
                                    ),
                                  ),
                                ),
                                ...yesterday.map(buildNotificationCard),
                              ],
                            ],
                          ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              role == 'student'
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
  }
}
