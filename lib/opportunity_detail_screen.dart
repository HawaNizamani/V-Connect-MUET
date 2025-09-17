import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Map<String, dynamic> opportunityData;
  final String opportunityId;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunityData,
    required this.opportunityId,
  });

  Future<void> _applyForOpportunity(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to apply.")),
      );
      return;
    }

    try {
      final applicationsRef = FirebaseFirestore.instance.collection('applications');

      // Check if the user already applied
      final existing = await applicationsRef
          .where('uid', isEqualTo: user.uid)
          .where('opportunityId', isEqualTo: opportunityId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have already applied for this opportunity.")),
        );
        return;
      }

      // Get orgId (check your opportunities collection field name!)
      final orgId = opportunityData['orgId']?.toString() ??
          opportunityData['ownerId']?.toString();
      if (orgId == null || orgId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Opportunity missing organization ID.")),
        );
        return;
      }

      // Build opportunity description
      final oppDescription = (opportunityData['description'] != null &&
          opportunityData['description'].toString().isNotEmpty)
          ? opportunityData['description']
          : 'Location: ${opportunityData['location'] ?? 'N/A'}, '
          'Eligibility: ${opportunityData['eligibility'] ?? 'N/A'}, '
          'Skill: ${opportunityData['requiredSkill'] ?? 'N/A'}';

      // Add application document
      await applicationsRef.add({
        'uid': user.uid,
        'opportunityId': opportunityId,
        'title': opportunityData['title'] ?? '',
        'opportunityDescription': oppDescription,
        'status': 'pending',
        'orgId': orgId,
        'appliedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Applied successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error applying: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Opportunity Details"),
        backgroundColor: const Color(0xFF5D3A3A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              opportunityData['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Organization: ${opportunityData['name'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Location: ${opportunityData['location'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Deadline: ${opportunityData['deadline'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Eligibility: ${opportunityData['eligibility'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Required Skill: ${opportunityData['requiredSkill'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Type: ${opportunityData['type'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _applyForOpportunity(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D3A3A),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
