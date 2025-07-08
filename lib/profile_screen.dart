import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_bottom_navbar.dart';
import 'available_opportunities_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';

class ProfileScreen extends StatefulWidget {

  final String name;
  final String rollNo;
  final String department;
  final String skills;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.rollNo,
    required this.department,
    required this.skills,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final user = FirebaseAuth.instance.currentUser;

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  final List<Map<String, String>> experiences = [];
  File? _profileImage;

  Future<void> _pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  void _addExperienceDialog() {
    String title = '';
    String org = '';
    String duration = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Experience"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Title/Role',
                  prefixIcon: Icon(Icons.badge),
                ),
                onChanged: (val) => title = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Organization',
                  prefixIcon: Icon(Icons.business),
                ),
                onChanged: (val) => org = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g. Jan 2023 - Mar 2023)',
                  prefixIcon: Icon(Icons.access_time),
                ),
                onChanged: (val) => duration = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (title.isNotEmpty && org.isNotEmpty && duration.isNotEmpty) {
                setState(() {
                  experiences.add({
                    "title": title,
                    "organization": org,
                    "duration": duration,
                  });
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _onNavBarTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(
              name: widget.name,
              rollNo: widget.rollNo,
              department: widget.department,
              skills: widget.skills,
            ),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AvailableOpportunitiesScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);
    const Color glassColor = Colors.white30;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.85),
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/123_jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: kToolbarHeight + 20, bottom: 80),
            child: Column(
              children: [
                /// Profile Card with blur
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: glassColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                _profileImage != null ? FileImage(_profileImage!) : null,
                                child: _profileImage == null
                                    ? const Icon(Icons.camera_alt,
                                    color: primaryColor, size: 30)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.department}\n${widget.rollNo}\n${widget.skills}',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Edit'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: const BorderSide(color: primaryColor),
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.share, size: 16),
                                        label: const Text('Share'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: const BorderSide(color: primaryColor),
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14)
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                        alignment: Alignment.bottomRight,
                                        icon: const Icon(Icons.logout, color: primaryColor),
                                        tooltip: 'Logout',
                                        onPressed: (()=>signout()),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// Experience Section (Heading + Cards) with unified glass style
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: glassColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Heading and Add button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Previous Experiences',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                InkWell(
                                  onTap: _addExperienceDialog,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white70),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.add, size: 20, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Add',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            /// Experience cards
                            if (experiences.isEmpty)
                              const Text(
                                "No experience added yet.",
                                style: TextStyle(color: Colors.white70),
                              )
                            else
                              ...experiences.map(
                                    (exp) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading:
                                      const Icon(Icons.work_outline, color: Colors.white),
                                      title: Text(
                                        exp['title'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exp['organization'] ?? '',
                                            style:
                                            const TextStyle(color: Colors.white70),
                                          ),
                                          Text(
                                            exp['duration'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.white60),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _onNavBarTap(context, index),
      ),
    );
  }
}
