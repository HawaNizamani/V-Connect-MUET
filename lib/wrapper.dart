import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/login_screen.dart';
import 'package:v_connect_muet/organization_screen.dart';
import 'package:v_connect_muet/profile_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnapshot.data;

        // If user is not logged in
        if (user == null) {
          return const LoginScreen();
        }

        // If user is logged in, fetch Firestore profile
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // Firestore document missing → force logout
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null || !userData.containsKey('role')) {
              // Profile exists but is corrupted or incomplete → force logout
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            final role = userData['role'];

            if (role == 'student') {
              return ProfileScreen(userData: userData);
            } else if (role == 'organization') {
              return const Text('org'); // Replace with OrganizationScreen if ready
            } else {
              // Unknown role → force logout
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }
          },
        );

      },
    );
  }
}
