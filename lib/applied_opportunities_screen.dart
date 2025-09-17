import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/available_opportunities_screen.dart';
import 'package:v_connect_muet/profile_student_screen.dart';
import 'bottom_navbar_student.dart';
import 'chatbot_screen.dart';
import 'notification_screen.dart';

class AppliedOpportunitiesScreen extends StatefulWidget {
  const AppliedOpportunitiesScreen({super.key});

  @override
  State<AppliedOpportunitiesScreen> createState() =>
      _AppliedOpportunitiesScreenState();
}

class _AppliedOpportunitiesScreenState extends State<AppliedOpportunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _onNavTap(int index) async {
    if (index == 1) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AvailableOpportunitiesScreen()),
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
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
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

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAppliedOpportunities(String uid) async {
    final applicationsSnapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('uid', isEqualTo: uid)
        .get();

    List<Map<String, dynamic>> result = [];

    for (var appDoc in applicationsSnapshot.docs) {
      final appData = appDoc.data();
      final oppId = appData['opportunityId'];
      if (oppId == null) continue;

      final oppDoc = await FirebaseFirestore.instance
          .collection('opportunities')
          .doc(oppId)
          .get();

      if (!oppDoc.exists) continue;

      final oppData = oppDoc.data()!;
      result.add({
        ...oppData,
        'status': appData['status'] ?? 'pending', // merge status
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Applied Opportunities')),
      body: user == null
          ? const Center(child: Text("Please log in to view applied opportunities."))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search your applied opportunities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAppliedOpportunities(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No applied opportunities found."));
                  }

                  final opportunities = snapshot.data!
                      .where((opp) =>
                      (opp['title'] ?? '').toString().toLowerCase().contains(_searchQuery))
                      .toList();

                  if (opportunities.isEmpty) {
                    return const Center(child: Text("No matching opportunities."));
                  }

                  return ListView.builder(
                    itemCount: opportunities.length,
                    itemBuilder: (context, index) {
                      final data = opportunities[index];

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundImage: AssetImage('assets/images/wall_of_hope.png'),
                                    radius: 25,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'] ?? 'No Title',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(data['organizationName'] ?? 'No Organization'),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(data['location'] ?? 'No Location',
                                                style: const TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(data['type'] ?? 'No Type'),
                                    backgroundColor: const Color(0xFFEDEDED),
                                  ),
                                  const SizedBox(width: 6),
                                  Chip(
                                    label: Text(data['requiredSkill'] ?? 'No Skill'),
                                    backgroundColor: const Color(0xFFEDEDED),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['deadline'] ?? 'No Deadline',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Eligibility: ${data['eligibility'] ?? 'Not specified'}",
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Contact: ${data['contact'] ?? 'Not provided'}",
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${data['status']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (data['status'] == 'approved')
                                      ? Colors.green
                                      : (data['status'] == 'rejected')
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StudentNavbar(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }
}
