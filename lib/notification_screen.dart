import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedIndex = 3;

  // Sample notifications — replace with Firestore data if needed
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "New Opportunity: Blood Donation Drive",
      "subtitle": "Join us on 15th May at the Health Center",
      "time": "2 hours ago",
    },
    {
      "title": "Reminder: Tree Plantation",
      "subtitle": "Tomorrow at 10 AM in MUET Park",
      "time": "1 day ago",
    },
    {
      "title": "Application Status Update",
      "subtitle": "Your application for Beach Cleanup was approved",
      "time": "3 days ago",
    },
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/opportunities');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications available."))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(notif["title"]),
              subtitle: Text(notif["subtitle"]),
              trailing: Text(
                notif["time"],
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              leading: const Icon(Icons.notifications),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
