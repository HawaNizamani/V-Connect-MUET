import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'create_profile_screen.dart';
import 'profile_screen.dart';
import 'available_opportunities_screen.dart';
import 'chatbot_screen.dart';
import 'search_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';
import 'create_opportunity_screen.dart';
import 'organization_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'V-Connect MUET',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Set initial screen to Signup
      home: const SignupScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/create-profile': (context) => const CreateProfileScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/opportunities': (context) => const AvailableOpportunitiesScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/search': (context) => const SearchScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/create-opportunity': (context) => const CreateOpportunityScreen(),
        '/organizations': (context) => const OrganizationScreen(),
      },
    );
  }
}
