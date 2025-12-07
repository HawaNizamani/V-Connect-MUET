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

      // Check if already applied
      final existing = await applicationsRef
          .where('uid', isEqualTo: user.uid)
          .where('opportunityId', isEqualTo: opportunityId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You have already applied for this opportunity."),
          ),
        );
        return;
      }

      // Get organization ID
      final orgId = opportunityData['orgId']?.toString() ??
          opportunityData['ownerId']?.toString();
      if (orgId == null || orgId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Opportunity missing organization ID.")),
        );
        return;
      }

      // Build opportunity description
      final oppDescription =
      (opportunityData['description'] != null &&
          opportunityData['description'].toString().isNotEmpty)
          ? opportunityData['description']
          : 'Location: ${opportunityData['location'] ?? 'N/A'}, '
          'Eligibility: ${opportunityData['eligibility'] ?? 'N/A'}, '
          'Skill: ${opportunityData['requiredSkill'] ?? 'N/A'}';

      // Add new application
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
    const Color primaryColor = Color(0xFF0A3A8B);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Opportunity Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ✅ Opportunity Title
            Text(
              opportunityData['title'] ?? 'Opportunity',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A3A8B),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Organization name below title
            Text(
              opportunityData['organizationName'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Details Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(
                    label: "Location",
                    value: opportunityData['location'] ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  InfoRow(
                    label: "Deadline",
                    value: opportunityData['deadline'] ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  InfoRow(
                    label: "Eligibility",
                    value: opportunityData['eligibility'] ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  InfoRow(
                    label: "Required Skill",
                    value: opportunityData['requiredSkill'] ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  InfoRow(
                    label: "Type",
                    value: opportunityData['type'] ?? 'N/A',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ✅ Apply button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await _applyForOpportunity(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Apply",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Reusable InfoRow widget
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF0A3A8B),
      fontSize: 16,
    );
    const valueStyle = TextStyle(fontSize: 16, color: Colors.black87);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text("$label:", style: labelStyle)),
        Expanded(child: Text(value, style: valueStyle)),
      ],
    );
  }
}
