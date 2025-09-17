import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v_connect_muet/applied_opportunities_screen.dart';
import 'package:v_connect_muet/chatbot_screen.dart';
import 'package:v_connect_muet/profile_student_screen.dart';
import 'bottom_navbar_student.dart';
import 'opportunity_detail_screen.dart';
import 'notification_screen.dart';

class AvailableOpportunitiesScreen extends StatefulWidget {
  const AvailableOpportunitiesScreen({super.key});

  @override
  State<AvailableOpportunitiesScreen> createState() =>
      _AvailableOpportunitiesScreenState();
}

class _AvailableOpportunitiesScreenState extends State<AvailableOpportunitiesScreen> {
  final Set<int> favorites = {};

  void toggleFavorite(int index) {
    setState(() {
      if (favorites.contains(index)) {
        favorites.remove(index);
      } else {
        favorites.add(index);
      }
    });
  }

  void _onNavTap(int index) async {
    if (index == 0) return; // already on this screen

    switch (index) {
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);
    const Color backgroundColor = Color(0xFFF5F9FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Available Opportunities',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
            splashRadius: 24,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
            splashRadius: 24,
          ),
        ],
      ),
      body: buildOpportunityList(),
      bottomNavigationBar: StudentNavbar(
        currentIndex: 0,
        onTap: _onNavTap,
      ),
    );
  }

  Widget buildOpportunityList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('opportunities')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No opportunities available."));
        }

        final opportunities = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: opportunities.length,
          itemBuilder: (context, index) {
            final data = opportunities[index].data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OpportunityDetailScreen(
                      opportunityData: data,
                      opportunityId: opportunities[index].id,
                    ),
                  ),
                );
              },
              child: Card(
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(data['organizationName'] ?? 'No Organization'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(data['location'] ?? 'No Location',
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              favorites.contains(index)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favorites.contains(index) ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => toggleFavorite(index),
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
