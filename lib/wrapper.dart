import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v_connect_muet/create_profile_organization_screen.dart';
import 'package:v_connect_muet/create_profile_student_screen.dart';
import 'package:v_connect_muet/login_screen.dart';
import 'package:v_connect_muet/profile_screen.dart';
import 'package:v_connect_muet/organization_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final doc = userSnapshot.data!;
            if (!doc.exists) {
              // Wait for document to be created instead of signing out
              return LoginScreen();
            }

            final role = doc['role'];
            if (role == 'student') {
              return ProfileScreen(userData: doc.data() as Map<String, dynamic>);
            } else if (role == 'organization') {
              return Text('org');
                // OrganizationScreen(
                //   userData: doc.data() as Map<String, dynamic>);
            } else {
              return const Scaffold(
                body: Center(child: Text("Unknown role")),
              );
            }
          },
        );
      },
    );
  }
}
