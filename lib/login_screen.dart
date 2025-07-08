import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/constants.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:v_connect_muet/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  SignIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
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
                    mainAxisSize: MainAxisSize.min,
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
                        "Welcome to Volunteer Connect",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Confirm identity to proceed.",
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      const SizedBox(height: 24),
                      buildInputField(
                        controller: _emailController,
                        hint: "Email Address",
                        icon: LucideIcons.mail,
                      ),
                      const SizedBox(height: 16),
                      buildInputField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: LucideIcons.lock,
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                            color: accentColor,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                          onPressed: (()=>SignIn()),
                          // {
                          //   if (_formKey.currentState!.validate()) {
                          //     Navigator.pushNamed(
                          //       context,
                          //       '/profile_screen',
                          //     );
                          //   }
                          // },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          GestureDetector(
                            onTap:
                          // () => print("Signup"),
                          () => Get.to(SignupScreen()),
                            //     () => Navigator.pushNamed(
                            //   context,
                            //   '/signup_screen',
                            // ),
                            child: const Text(
                              "Sign up here",
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

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textHintColor),
        filled: true,
        fillColor: inputFillColor,
        prefixIcon: Icon(icon, color: accentColor),
        suffixIcon: suffixIcon,
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
          (value) => value == null || value.isEmpty ? 'Enter $hint' : null,
    );
  }
}
