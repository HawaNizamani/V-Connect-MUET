import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'bottom_navbar_organization.dart';
import 'dashboard_screen.dart';
import 'chatbot_screen.dart';
import 'notification_screen.dart';
import 'profile_organization_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final _userCache = <String, Map<String, dynamic>>{};
  User? _orgUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _orgUser = FirebaseAuth.instance.currentUser;
    print("=== ORG USER UID === ${_orgUser?.uid}");
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        break;
      case 1:
        return; // already on ApplicationsScreen
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileOrganizationScreen()),
        );
        break;
    }
  }

  Future<Map<String, dynamic>?> _getStudent(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid];
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) _userCache[uid] = data;
    return data;
  }

  Future<void> _updateStatus(String appId, String status) async {
    await _firestore.collection('applications').doc(appId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Delete applications if their related opportunity no longer exists
  Future<void> _deleteIfOpportunityMissing(
      String appId, String opportunityId) async {
    final oppDoc =
    await _firestore.collection('opportunities').doc(opportunityId).get();
    if (!oppDoc.exists) {
      await _firestore.collection('applications').doc(appId).delete();
      debugPrint("🗑️ Deleted orphaned application: $appId");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);
    const Color backgroundColor = Color(0xFFF5F9FF);

    if (_orgUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in as an organization')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Manage Applications',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('applications')
                    .where('orgId', isEqualTo: _orgUser!.uid)
                    .orderBy('appliedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No applications yet.'));
                  }

                  final apps = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final appDoc = apps[index];
                      final appData = appDoc.data() as Map<String, dynamic>;

                      final uid = (appData['uid'] ?? '').toString();
                      final oppTitle = (appData['title'] ?? 'No Title').toString();
                      final oppId = (appData['opportunityId'] ?? '').toString();
                      final status = (appData['status'] ?? 'pending').toString();
                      final appliedAt = appData['appliedAt'] is Timestamp
                          ? (appData['appliedAt'] as Timestamp).toDate()
                          : null;

                      // ✅ Delete app if its opportunity no longer exists
                      if (oppId.isNotEmpty) {
                        _deleteIfOpportunityMissing(appDoc.id, oppId);
                      }

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _getStudent(uid),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(child: Icon(Icons.person)),
                                title: Text('Loading...'),
                                subtitle: Text('Fetching student info'),
                              ),
                            );
                          }

                          final student = snap.data ?? {};
                          final studentName =
                          (student['name'] ?? 'Unknown Student').toString();
                          final studentEmail =
                          (student['email'] ?? '').toString();

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            child: ListTile(
                              leading:
                              const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(studentName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: $studentEmail'),
                                  Text('Applied for: $oppTitle'),
                                  if (appliedAt != null)
                                    Text(
                                        'Applied at: ${appliedAt.day}/${appliedAt.month}/${appliedAt.year}'),
                                  Text('Status: ${status.toUpperCase()}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check_circle,
                                        color: status == 'approved'
                                            ? Colors.grey
                                            : Colors.green),
                                    onPressed: status == 'approved'
                                        ? null
                                        : () => _updateStatus(
                                        appDoc.id, 'approved'),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.cancel,
                                        color: status == 'rejected'
                                            ? Colors.grey
                                            : Colors.red),
                                    onPressed: status == 'rejected'
                                        ? null
                                        : () => _updateStatus(
                                        appDoc.id, 'rejected'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: OrganizationNavbar(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}
