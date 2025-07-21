// import 'package:flutter/material.dart';
// import 'custom_bottom_navbar.dart';
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   int _selectedIndex = 0;
//
//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//     switch (index) {
//       case 0:
//         Navigator.pushReplacementNamed(context, '/profile');
//         break;
//       case 1:
//         Navigator.pushReplacementNamed(context, '/opportunities');
//         break;
//       case 2:
//         Navigator.pushReplacementNamed(context, '/search');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/notifications');
//         break;
//     }
//   }
//
//   void _showComingSoon(String title) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('$title coming soon!')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text("Edit Profile"),
//             onTap: () => _showComingSoon("Edit Profile"),
//           ),
//           ListTile(
//             leading: const Icon(Icons.notifications),
//             title: const Text("Notification Settings"),
//             onTap: () => _showComingSoon("Notification Settings"),
//           ),
//           ListTile(
//             leading: const Icon(Icons.lock),
//             title: const Text("Change Password"),
//             onTap: () => _showComingSoon("Change Password"),
//           ),
//           ListTile(
//             leading: const Icon(Icons.dark_mode),
//             title: const Text("App Theme"),
//             onTap: () => _showComingSoon("App Theme"),
//           ),
//           ListTile(
//             leading: const Icon(Icons.help_outline),
//             title: const Text("Help & Support"),
//             onTap: () => _showComingSoon("Help & Support"),
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text("Logout", style: TextStyle(color: Colors.red)),
//             onTap: () {
//               // Add actual logout logic
//               Navigator.pushReplacementNamed(context, '/');
//             },
//           ),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
