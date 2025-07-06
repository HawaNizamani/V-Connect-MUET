import 'dart:ui';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class CreateProfileStudentScreen extends StatefulWidget {
  const CreateProfileStudentScreen({super.key});

  @override
  State<CreateProfileStudentScreen> createState() =>
      _CreateProfileStudentScreenState();
}

class _CreateProfileStudentScreenState
    extends State<CreateProfileStudentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);
    const Color greenAccent = Color(0xFF00C896);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/123_jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          'Create Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildInputField(
                          label: 'Name',
                          icon: Icons.person_outline,
                          controller: nameController,
                        ),
                        buildInputField(
                          label: 'Roll Number',
                          icon: Icons.confirmation_number,
                          controller: rollController,
                        ),
                        buildInputField(
                          label: 'Department',
                          icon: Icons.school,
                          controller: deptController,
                        ),
                        buildInputField(
                          label: 'Skills',
                          icon: Icons.code,
                          controller: skillsController,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(
                                    name: nameController.text.trim(),
                                    rollNo: rollController.text.trim(),
                                    department: deptController.text.trim(),
                                    skills: skillsController.text.trim(),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Create Profile",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Back",
                            style: TextStyle(color: greenAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.85),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: Icon(icon, color: Color(0xFF0A1D56)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
