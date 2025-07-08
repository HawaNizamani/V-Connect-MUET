import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProfileOrganizationScreen extends StatefulWidget {
  const CreateProfileOrganizationScreen({super.key});

  @override
  State<CreateProfileOrganizationScreen> createState() => _CreateProfileOrganizationScreenState();
}

class _CreateProfileOrganizationScreenState extends State<CreateProfileOrganizationScreen> {
  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56); // Navy blue

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
                        buildInputField(label: 'Organization Name', icon: Icons.business, controller: orgNameController),
                        buildInputField(label: 'Email', icon: Icons.email_outlined, controller: emailController),
                        buildInputField(label: 'Phone', icon: Icons.phone, controller: phoneController),
                        buildInputField(label: 'Address', icon: Icons.location_on_outlined, controller: addressController),
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
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .set({
                                  'uid': user.uid,
                                  'role': 'organization',
                                  'organizationName': orgNameController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'phone': phoneController.text.trim(),
                                  'address': addressController.text.trim(),
                                });

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User not logged in')),
                                );
                              }
                            },
                            child: const Text(
                              "Create Profile",
                              style: TextStyle(fontSize: 16),
                            ),
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
