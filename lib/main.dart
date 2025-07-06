import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/create_profile_organization_screen.dart';
import 'package:v_connect_muet/create_profile_student_screen.dart';
import 'package:v_connect_muet/login_screen.dart';
import 'package:v_connect_muet/profile_screen.dart';
import 'package:v_connect_muet/signup_screen.dart';
import 'package:get/get.dart';
import 'package:v_connect_muet/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'V-Connect MUET',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Set initial screen to Signup
      home: const Wrapper(),
      routes: {
        '/signup_screen': (context) => SignupScreen(),
        '/login_screen': (context) => LoginScreen(),
        '/create_profile_student': (context) => CreateProfileStudentScreen(),
        '/create_profile_organization': (context) => CreateProfileOrganizationScreen(),
        '/profile_screen' : (context) => ProfileScreen(name: 'name', rollNo: 'rollNo', department: 'department', skills: 'skills')
      },
    );
  }
}
