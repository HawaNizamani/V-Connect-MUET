import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/applied_opportunities_screen.dart';
import 'package:v_connect_muet/create_profile_organization_screen.dart';
import 'package:v_connect_muet/create_profile_student_screen.dart';
import 'package:v_connect_muet/login_screen.dart';
import 'package:v_connect_muet/profile_organization_screen.dart';
import 'package:v_connect_muet/profile_student_screen.dart';
import 'package:v_connect_muet/signup_screen.dart';
import 'package:get/get.dart';
import 'package:v_connect_muet/wrapper.dart';
import 'package:v_connect_muet/splash_screen.dart';

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
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/wrapper', page: () => const Wrapper()),
        GetPage(name: '/login_screen', page: () => const LoginScreen()),
        GetPage(name: '/signup_screen', page: () => const SignupScreen()),
        GetPage(name: '/create_profile_student_screen', page: () => const CreateProfileStudentScreen()),
        GetPage(name: '/create_profile_organization_screen', page: () => const CreateProfileOrganizationScreen()),
        GetPage(name: '/applied_opportunities_screen', page: () => const AppliedOpportunitiesScreen()),
        // Add others as needed
      ],
    );
  }
}
