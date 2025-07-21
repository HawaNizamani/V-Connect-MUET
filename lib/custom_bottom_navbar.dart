import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String role; // 'student' or 'organization'

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final bool isStudent = role == 'student';

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: isStudent
          ? const [
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Opportunities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: 'Applied',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ]
          : const [
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Opportunities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.post_add),
          label: 'Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
