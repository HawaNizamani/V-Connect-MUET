import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() => _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  final Color primaryColor = const Color(0xFF0A1D56);

  // Controllers for form input
  final titleController = TextEditingController();
  final orgNameController = TextEditingController();
  final eligibilityController = TextEditingController();
  final locationController = TextEditingController();
  final deadlineController = TextEditingController();
  final contactController = TextEditingController();

  // Dropdown selections
  String? opportunityType;
  String? requiredSkill;

  bool isLoading = false;

  Future<void> _saveOpportunity() async {
    if (titleController.text.isEmpty ||
        orgNameController.text.isEmpty ||
        opportunityType == null ||
        requiredSkill == null ||
        eligibilityController.text.isEmpty ||
        locationController.text.isEmpty ||
        deadlineController.text.isEmpty ||
        contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in as an organization")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('opportunities').add({
        'title': titleController.text.trim(),
        'organizationName': orgNameController.text.trim(),
        'type': opportunityType,
        'requiredSkill': requiredSkill,
        'eligibility': eligibilityController.text.trim(),
        'location': locationController.text.trim(),
        'contact': contactController.text.trim(),
        'deadline': deadlineController.text.trim(),
        'ownerId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opportunity created successfully")),
      );

      Navigator.pop(context); // Go back to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Create Opportunity', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('Title', controller: titleController),
            const SizedBox(height: 12),
            _buildTextField('Organization Name', controller: orgNameController),
            const SizedBox(height: 12),
            _buildDropdownField(
              'Opportunity Type',
              ['Internship', 'Job', 'Scholarship', 'Volunteering'],
                  (val) => setState(() => opportunityType = val),
            ),
            const SizedBox(height: 12),
            _buildDropdownField(
              'Required Skill',
              ['Programming', 'Design', 'Marketing', 'Research'],
                  (val) => setState(() => requiredSkill = val),
            ),
            const SizedBox(height: 12),
            _buildTextField('Eligibility Criteria', controller: eligibilityController),
            const SizedBox(height: 12),
            _buildTextField('Location', controller: locationController),
            const SizedBox(height: 12),
            _buildDateField('Application Deadline', controller: deadlineController),
            const SizedBox(height: 12),
            _buildTextField('Contact Email / Phone', controller: contactController),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Optional - preview feature
                    },
                    child: const Text('View as applicant'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: isLoading ? null : _saveOpportunity,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Proceed', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {TextEditingController? controller, String? prefixText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: null,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(String label, {required TextEditingController controller}) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toString().split(' ')[0];
        }
      },
    );
  }
}
