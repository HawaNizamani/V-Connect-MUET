import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_bottom_navbar.dart';

class RoleBasedScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RoleBasedScaffold({
    Key? key,
    required this.body,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  Future<String?> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role']; // Make sure 'role' exists in Firestore
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;

        return Scaffold(
          body: body,
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            role: role,
          ),
        );
      },
    );
  }
}
