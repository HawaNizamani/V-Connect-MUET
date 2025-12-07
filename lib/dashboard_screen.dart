import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'applications_screen.dart';
import 'bottom_navbar_organization.dart';
import 'chatbot_screen.dart';
import 'create_opportunity_screen.dart';
import 'notification_screen.dart';
import 'profile_organization_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to login screen after logout
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
  }

  void _onNavTap(int index) {
    if (index == 0) return;

    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ApplicationsScreen()),
        );
        break;
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
          MaterialPageRoute(builder: (_) => ProfileOrganizationScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);
    const Color backgroundColor = Color(0xFFF5F9FF);

    final orgId = _auth.currentUser?.uid;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: buildSideDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState!.openDrawer(),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.business, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            if (orgId != null)
              StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('opportunities')
                        .where('ownerId', isEqualTo: orgId)
                        .snapshots(),
                builder: (context, postSnap) {
                  if (postSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (postSnap.hasError) {
                    return Center(child: Text("Error: ${postSnap.error}"));
                  }

                  final posts = postSnap.data?.docs ?? [];
                  final postsCount = posts.length;
                  final oppIds = posts.map((doc) => doc.id).toList();

                  if (oppIds.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildStatCard(
                            'Posts',
                            postsCount.toString(),
                            primaryColor,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard('Applications', "0", Colors.green),
                          const SizedBox(width: 12),
                          _buildStatCard('Pending', "0", Colors.orange),
                        ],
                      ),
                    );
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        _firestore
                            .collection('applications')
                            .where('orgId', isEqualTo: orgId)
                            .snapshots(),
                    builder: (context, appSnap) {
                      if (appSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (appSnap.hasError) {
                        return Center(child: Text("Error: ${appSnap.error}"));
                      }

                      final applications = appSnap.data?.docs ?? [];
                      final applicationsCount = applications.length;
                      final pendingCount =
                          applications
                              .where((doc) => doc['status'] == 'pending')
                              .length;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildStatCard(
                              'Posts',
                              postsCount.toString(),
                              primaryColor,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Applications',
                              applicationsCount.toString(),
                              Colors.green,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Pending',
                              pendingCount.toString(),
                              Colors.orange,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 16),

            // Create Opportunity Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Opportunity'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateOpportunityScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Posts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            Expanded(child: _buildMyPostsList(orgId!)),
          ],
        ),
      ),
      bottomNavigationBar: OrganizationNavbar(
        currentIndex: 0,
        onTap: _onNavTap,
      ),
    );
  }

  static Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPostsList(String orgId) {
    final _firestore = FirebaseFirestore.instance;

    Future<void> _deleteOpportunity(String oppId) async {
      try {
        // Delete opportunity
        await _firestore.collection('opportunities').doc(oppId).delete();

        // Delete related applications
        final apps =
            await _firestore
                .collection('applications')
                .where('opportunityId', isEqualTo: oppId)
                .get();
        for (var doc in apps.docs) {
          await _firestore.collection('applications').doc(doc.id).delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('opportunities')
              .where('ownerId', isEqualTo: orgId)
              .snapshots(),
      builder: (context, postSnap) {
        if (postSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (postSnap.hasError) {
          return Center(child: Text("Error: ${postSnap.error}"));
        }

        final posts = postSnap.data?.docs ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text("No posts yet"));
        }

        return StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('applications')
                  .where('orgId', isEqualTo: orgId)
                  .snapshots(),
          builder: (context, appSnap) {
            if (appSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (appSnap.hasError) {
              return Center(child: Text("Error: ${appSnap.error}"));
            }

            final applications = appSnap.data?.docs ?? [];

            final Map<String, List<QueryDocumentSnapshot>> appsByPost = {};
            for (var app in applications) {
              final oppId = app['opportunityId'];
              appsByPost.putIfAbsent(oppId, () => []);
              appsByPost[oppId]!.add(app);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final postId = post.id;
                final postTitle = post['title'] ?? "Untitled";

                final postApps = appsByPost[postId] ?? [];
                final totalApps = postApps.length;
                final pendingApps =
                    postApps.where((app) => app['status'] == 'pending').length;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: ListTile(
                    title: Text(postTitle),
                    subtitle: Text(
                      "Applications: $totalApps | Pending: $pendingApps",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                      'Are you sure you want to delete this opportunity?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              await _deleteOpportunity(postId);
                            }
                          },
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      // Navigate to post details
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildSideDrawer() {
    const Color primaryColor = Color(0xFF0A1D56);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;
          final name = user['name'] ?? "No Name";
          final email = user['email'] ?? "No Email";

          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: primaryColor),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.business, color: Colors.grey, size: 40),
                ),
                accountName: Text(name),
                accountEmail: Text(email),
              ),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Settings tapped")),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favourites'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Favourites tapped")),
                  );
                },
              ),

              const Spacer(),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _signOut,
              ),
            ],
          );
        },
      ),
    );
  }

}
