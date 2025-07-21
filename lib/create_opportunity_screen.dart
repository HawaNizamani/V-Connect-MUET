import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v_connect_muet/available_opportunities_screen.dart';
import 'package:v_connect_muet/profile_organization_screen.dart';
import 'package:v_connect_muet/notification_screen.dart';
import 'package:v_connect_muet/chatbot_screen.dart';
import 'package:v_connect_muet/create_opportunity_screen.dart';
import 'custom_bottom_navbar.dart';

class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() => _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _onNavTap(int index) async {
    if (index == 1) return; // already on this screen

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
                builder: (_) => ProfileOrganizationScreen(userData: userData),
              ),
            );
          }
        }
        break;
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final description = _descriptionController.text;
      final location = _locationController.text;
      final date = _selectedDate?.toLocal().toString().split(' ')[0] ?? '';
      final time = _selectedTime?.format(context) ?? '';

      // TODO: Upload to Firestore or backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opportunity created successfully!")),
      );

      _formKey.currentState?.reset();
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Opportunity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value == null || value.isEmpty ? 'Enter location' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedTime == null
                        ? 'Select Time'
                        : 'Time: ${_selectedTime!.format(context)}'),
                  ),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text('Pick Time'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.check),
                label: const Text('Create Opportunity'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, // Opportunities tab
        role: 'organization', // fixed role for student screen
        onTap: _onNavTap, // overridden below
      ),
    );
  }
}
