import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v_connect_muet/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      Get.offAllNamed('/wrapper'); // Navigate to login or wrapper
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/123_jpg', // same background image you used in Signup
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: const Color.fromARGB(30, 0, 0, 0),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.volunteer_activism,
                  size: 72,
                  color: Color.fromARGB(255, 38, 141, 24),
                ),
                const SizedBox(height: 16),
                const Text(
                  'V-Connect MUET',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 13, 48),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Connecting Students to Serve and Grow',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
