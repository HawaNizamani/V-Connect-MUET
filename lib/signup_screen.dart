import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/constants.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:v_connect_muet/wrapper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  String _selectedTab = 'Student';
  bool _isOtherSelected = false;

  final _formKey = GlobalKey<FormState>();

  final _studentNameController = TextEditingController();
  final _studentRollController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();
  final _studentConfirmPasswordController = TextEditingController();

  final _orgNameController = TextEditingController();
  final _orgEmailController = TextEditingController();
  final _orgPasswordController = TextEditingController();
  final _orgConfirmPasswordController = TextEditingController();
  final _orgTypeController = TextEditingController();

  signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTab == 'Student') {
      if (_studentPasswordController.text != _studentConfirmPasswordController.text) {
        Get.snackbar("Error", "Passwords do not match", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    } else {
      if (_orgPasswordController.text != _orgConfirmPasswordController.text) {
        Get.snackbar("Error", "Passwords do not match", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }

    try {
      // Create user using Firebase Auth
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _selectedTab == 'Student'
            ? _studentEmailController.text.trim()
            : _orgEmailController.text.trim(),
        password: _selectedTab == 'Student'
            ? _studentPasswordController.text.trim()
            : _orgPasswordController.text.trim(),
      );

      // Save extra data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
        'role': _selectedTab,
        'email': _selectedTab == 'Student'
            ? _studentEmailController.text.trim()
            : _orgEmailController.text.trim(),
        'name': _selectedTab == 'Student'
            ? _studentNameController.text.trim()
            : _orgNameController.text.trim(),
        if (_selectedTab == 'Student')
          'rollNumber': _studentRollController.text.trim(),
        if (_selectedTab == 'Organization')
          'orgType': _orgTypeController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      Get.snackbar("Success", "Account created successfully!", backgroundColor: Colors.green, colorText: Colors.white);

      if (_selectedTab == 'Student') {
        Get.offAllNamed('/create_profile_student_screen');
      } else {
        Get.offAllNamed('/create_profile_organization_screen');
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Signup Failed", e.message ?? "Unknown error", backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  final List<String> _orgTypes = [
    "Academic",
    "Social",
    "Society",
    "Social Work",
    "Sports",
    "Tech",
    "Other",
  ];

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentRollController.dispose();
    _studentEmailController.dispose();
    _studentPasswordController.dispose();
    _studentConfirmPasswordController.dispose();
    _orgNameController.dispose();
    _orgEmailController.dispose();
    _orgPasswordController.dispose();
    _orgConfirmPasswordController.dispose();
    _orgTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/123_jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: const Color.fromARGB(30, 0, 0, 0)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(100, 173, 216, 255),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.graduationCap,
                            color: Color.fromARGB(255, 38, 141, 24),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "V-Connect MUET",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 0, 13, 48),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Registration",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Start your journey with Volunteer Connect",
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      const SizedBox(height: 16),

                      // Toggle Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            buildTabButton('Student'),
                            buildTabButton('Organization'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dynamic Form Content
                      if (_selectedTab == 'Student') ...[
                        buildTextField(
                          "Student Name",
                          LucideIcons.user,
                          _studentNameController,
                        ),
                        buildTextField(
                          "Roll Number",
                          LucideIcons.badgeInfo,
                          _studentRollController,
                        ),
                        buildTextField(
                          "Email",
                          LucideIcons.mail,
                          _studentEmailController,
                        ),
                        buildPasswordField(
                          "Password",
                          _studentPasswordController,
                          true,
                        ),
                        buildPasswordField(
                          "Confirm Password",
                          _studentConfirmPasswordController,
                          false,
                        ),
                      ] else ...[
                        buildTextField(
                          "Organization Name",
                          LucideIcons.building,
                          _orgNameController,
                        ),
                        buildOrgTypeDropdownField(),
                        buildTextField(
                          "Email",
                          LucideIcons.mail,
                          _orgEmailController,
                        ),
                        buildPasswordField(
                          "Password",
                          _orgPasswordController,
                          true,
                        ),
                        buildPasswordField(
                          "Confirm Password",
                          _orgConfirmPasswordController,
                          false,
                        ),
                      ],

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged:
                                (value) => setState(() => _rememberMe = value!),
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              0,
                              13,
                              48,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: (()=>signup()),
                          // {
                          //   if (_formKey.currentState!.validate()) {
                          //     Navigator.pushNamed(
                          //       context,
                          //       '/create_profile_${_selectedTab.toLowerCase()}',
                          //     );
                          //   }
                          // },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Already have account link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  '/login_screen',
                                ),
                            child: const Text(
                              "Login Here",
                              style: TextStyle(
                                color: Color.fromARGB(255, 38, 141, 24),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabButton(String tabName) {
    final bool isSelected = _selectedTab == tabName;
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor:
              isSelected
                  ? tabSelectedColor.withOpacity(0.2)
                  : Colors.transparent,
        ),
        onPressed: () => setState(() => _selectedTab = tabName),
        child: Text(
          tabName,
          style: TextStyle(
            color: isSelected ? tabSelectedColor : tabUnselectedColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: textHintColor),
          filled: true,
          fillColor: inputFillColor,
          prefixIcon: Icon(icon, color: accentColor),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator:
            (value) => value == null || value.isEmpty ? "Enter $hint" : null,
      ),
    );
  }

  Widget buildPasswordField(
    String hint,
    TextEditingController controller,
    bool isMain,
  ) {
    final obscure = isMain ? _obscurePassword : _obscureConfirmPassword;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: textHintColor),
          filled: true,
          fillColor: inputFillColor,
          prefixIcon: const Icon(LucideIcons.lock, color: accentColor),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? LucideIcons.eyeOff : LucideIcons.eye,
              color: accentColor,
            ),
            onPressed:
                () => setState(() {
                  if (isMain) {
                    _obscurePassword = !_obscurePassword;
                  } else {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  }
                }),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator:
            (value) => value == null || value.isEmpty ? "Enter $hint" : null,
      ),
    );
  }

  Widget buildOrgTypeDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _orgTypeController,
        readOnly: !_isOtherSelected,
        onTap: () async {
          if (!_isOtherSelected) {
            final value = await showDialog<String>(
              context: context,
              builder:
                  (context) => SimpleDialog(
                    title: const Text('Select Organization Type'),
                    children:
                        _orgTypes.map((type) {
                          return SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, type),
                            child: Text(type),
                          );
                        }).toList(),
                  ),
            );
            if (value != null) {
              setState(() {
                if (value == 'Other') {
                  _isOtherSelected = true;
                  _orgTypeController.clear();
                } else {
                  _orgTypeController.text = value;
                  _isOtherSelected = false;
                }
              });
            }
          }
        },
        style: const TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: "Organization Type/Domain",
          hintStyle: const TextStyle(color: textHintColor),
          filled: true,
          fillColor: inputFillColor,
          prefixIcon: const Icon(LucideIcons.aperture, color: accentColor),
          suffixIcon: const Icon(LucideIcons.chevronDown, color: accentColor),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? "Please select or enter organization type"
                    : null,
      ),
    );
  }
}
