import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:v_connect_muet/applications_screen.dart';
import 'package:v_connect_muet/bottom_navbar_organization.dart';
import 'package:v_connect_muet/chatbot_screen.dart';
import 'package:v_connect_muet/dashboard_screen.dart';
import 'package:v_connect_muet/notification_screen.dart';

class ProfileOrganizationScreen extends StatefulWidget {
  const ProfileOrganizationScreen({super.key});

  @override
  State<ProfileOrganizationScreen> createState() => _ProfileOrganizationScreenState();
}

class _ProfileOrganizationScreenState extends State<ProfileOrganizationScreen> {
  File? _profileImage;
  bool isEditMode = false;
  bool _loading = true;

  _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Controllers (start empty so missing Firestore fields don't show placeholders as values)
  final nameController = TextEditingController();
  final websiteController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final foundedController = TextEditingController();
  final orgTypeController = TextEditingController();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadOrgData();
  }

  Future<void> _loadOrgData() async {
    try {
      if (_uid == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No logged-in user found.')),
        );
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      final data = doc.data();

      // If data exists, hydrate controllers; otherwise leave them empty
      if (data != null) {
        nameController.text = (data['name'] ?? '').toString();
        websiteController.text = (data['website'] ?? '').toString();
        descriptionController.text = (data['description'] ?? '').toString();
        addressController.text = (data['address'] ?? '').toString();
        emailController.text = (data['email'] ?? '').toString();
        contactController.text = (data['contact'] ?? '').toString();
        foundedController.text = (data['founded'] ?? '').toString();
        orgTypeController.text = (data['orgType'] ?? '').toString();
        // If later you store an image URL, you can also load it here (not implemented since UI uses local file only).
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveOrgData() async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Cannot save.')),
      );
      return;
    }

    try {
      // Build a map of only the fields we manage here.
      final update = <String, dynamic>{
        'role': 'organization', // optional: helps your Wrapper logic
        'name': nameController.text.trim(),
        'website': websiteController.text.trim(),
        'description': descriptionController.text.trim(),
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
        'contact': contactController.text.trim(),
        'founded': foundedController.text.trim(),
        'orgType': orgTypeController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Use set with merge so we don't overwrite unrelated fields
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .set(update, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() => isEditMode = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  void _pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
      // If you want to persist the image, upload to Firebase Storage and save the URL in Firestore.
    }
  }

  void _onNavTap(int index) async {
    if (index == 4) return; // already on this screen

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ApplicationsScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
        break;
    }
  }

  void _toggleEdit() {
    setState(() => isEditMode = true);
  }

  void _showPopupMenu() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx + 260, offset.dy + 60, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          onTap: _toggleEdit,
          child: Row(
            children: const [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text("Edit Profile"),
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.share, size: 18),
              SizedBox(width: 8),
              Text("Share Profile"),
            ],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Share tapped")));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);

    return Scaffold(
      backgroundColor: Colors.grey[200],

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0A1D56)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.business, color: Colors.grey, size: 40),
              ),
              accountName: Text(nameController.text.isNotEmpty ? nameController.text : 'No Name'),
              accountEmail: Text(emailController.text.isNotEmpty ? emailController.text : 'No Email'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings tapped")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favourites'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Favourites tapped")),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _signOut,
            ),
          ],
        ),
      ),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        titleSpacing: 16,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showPopupMenu,
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white,),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              // Top blue section
              Container(
                width: double.infinity,
                color: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isEditMode ? _pickProfileImage : null,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(Icons.business, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildEditableField(
                      nameController,
                      isEditMode,
                      fontSize: 20,
                      color: Colors.white,
                      isCenter: true,
                      placeholder: "Organization Name",
                      hideUnderline: !isEditMode,
                    ),
                    const SizedBox(height: 6),
                    buildEditableField(
                      websiteController,
                      isEditMode,
                      fontSize: 16,
                      color: Colors.white70,
                      isCenter: true,
                      placeholder: "Website",
                      hideUnderline: !isEditMode,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isEditMode
                          ? buildEditableField(
                        descriptionController,
                        true,
                        placeholder: "Description",
                        color: Colors.white,
                        maxLines: 3,
                      )
                          : Text(
                        descriptionController.text,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // White bottom section with slim cards
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  children: [
                    buildInfoCard(
                      icon: Icons.location_on,
                      controller: addressController,
                      editable: isEditMode,
                      placeholder: "Address",
                    ),
                    const SizedBox(height: 12),
                    buildInfoCard(
                      icon: Icons.email,
                      controller: emailController,
                      editable: isEditMode,
                      placeholder: "Email",
                    ),
                    const SizedBox(height: 12),
                    buildInfoCard(
                      icon: Icons.phone,
                      controller: contactController,
                      editable: isEditMode,
                      placeholder: "Contact Number",
                    ),
                    const SizedBox(height: 12),
                    buildInfoCard(
                      icon: Icons.calendar_today,
                      controller: foundedController,
                      editable: isEditMode,
                      placeholder: "Founded Year",
                    ),
                    const SizedBox(height: 12),
                    buildInfoCard(
                      icon: Icons.apartment,
                      controller: orgTypeController,
                      editable: isEditMode,
                      placeholder: "Organization Type",
                    ),
                    const SizedBox(height: 24),
                    if (isEditMode)
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          onPressed: _saveOrgData,
                          child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: OrganizationNavbar(currentIndex: 4, onTap: _onNavTap),
    );
  }

  // Slim info card builder
  Widget buildInfoCard({
    required IconData icon,
    required TextEditingController controller,
    required bool editable,
    String? placeholder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: editable
                ? TextFormField(
              controller: controller,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
              ),
            )
                : Text(
              controller.text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditableField(
      TextEditingController controller,
      bool editable, {
        String? placeholder,
        double fontSize = 14,
        Color color = Colors.black,
        bool isCenter = false,
        int maxLines = 1,
        bool hideUnderline = false,
      }) {
    return editable
        ? TextFormField(
      controller: controller,
      textAlign: isCenter ? TextAlign.center : TextAlign.start,
      maxLines: maxLines,
      style: TextStyle(color: color, fontSize: fontSize),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: color.withOpacity(0.7)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: hideUnderline ? Colors.transparent : color.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: hideUnderline ? Colors.transparent : color,
            width: 1.2,
          ),
        ),
      ),
    )
        : Text(
      controller.text,
      textAlign: isCenter ? TextAlign.center : TextAlign.start,
      style: TextStyle(fontSize: fontSize, color: color),
    );
  }
}
