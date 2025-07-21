import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_connect_muet/applied_opportunities_screen.dart';
import 'package:v_connect_muet/available_opportunities_screen.dart';
import 'package:v_connect_muet/chatbot_screen.dart';
import 'package:v_connect_muet/notification_screen.dart';
import 'custom_bottom_navbar.dart';

class ProfileOrganizationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileOrganizationScreen({super.key, required this.userData});

  @override
  State<ProfileOrganizationScreen> createState() => _ProfileOrganizationScreenState();
}

class _ProfileOrganizationScreenState extends State<ProfileOrganizationScreen> {
  File? _profileImage;
  bool isEditMode = false;

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  late TextEditingController nameController;
  late TextEditingController professionController;
  late TextEditingController batchController;
  late TextEditingController departmentController;
  late TextEditingController bioController;


  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.userData['name'] ?? '');
    professionController = TextEditingController(text: widget.userData['profession'] ?? '');
    batchController = TextEditingController(text: widget.userData['batch'] ?? '');
    departmentController = TextEditingController(text: widget.userData['department'] ?? '');
    bioController = TextEditingController(text: widget.userData['bio'] ?? '');
  }

  Future<void> updateUserData() async {
    final uid = widget.userData['uid'];
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': nameController.text.trim(),
      'profession': professionController.text.trim(),
      'batch': batchController.text.trim(),
      'department': departmentController.text.trim(),
      'bio': bioController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated")));
    setState(() => isEditMode = false);
  }

  void _pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
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
              SizedBox(width: 6),
              Text("Edit Profile"),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: signout,
          child: Row(
            children: [
              Icon(Icons.logout, size: 18,),
              SizedBox(width: 6,),
              Text('Logout')
            ],
          ),
        )
      ],
    );
  }

  void _onNavTap(int index) async {
    if (index == 4) return; // already on this screen

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AvailableOpportunitiesScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppliedOpportunitiesScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => NotificationScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        titleSpacing: 16,
        title: const Text('Student Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showPopupMenu,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
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
                      placeholder: "Name",
                      hideUnderline: !isEditMode,
                    ),
                    const SizedBox(height: 6),
                    buildEditableField(
                      professionController,
                      isEditMode,
                      fontSize: 16,
                      color: Colors.white70,
                      isCenter: true,
                      placeholder: "Skill / Profession",
                      underlineWidth: isEditMode ? 180 : null,
                      hideUnderline: !isEditMode,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isEditMode
                          ? Row(
                        children: [
                          Expanded(
                            child: buildEditableField(
                              batchController,
                              true,
                              placeholder: "Batch",
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(height: 20, width: 2, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: buildEditableField(
                              departmentController,
                              true,
                              placeholder: "Department",
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(batchController.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(width: 8),
                          Container(height: 16, width: 2, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(departmentController.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isEditMode
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text("Bio", style: TextStyle(color: Colors.white70)),
                          ),
                          buildEditableField(
                            bioController,
                            true,
                            placeholder: "Write about yourself",
                            color: Colors.white,
                          ),
                        ],
                      )
                          : Text(
                        bioController.text,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isEditMode)
                ElevatedButton(
                  onPressed: () async {
                    final uid = widget.userData['uid'] ?? FirebaseAuth.instance.currentUser?.uid;

                    if (uid == null || uid.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User ID not found. Cannot update data.')),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({
                        'name': nameController.text.trim(),
                        'department': departmentController.text.trim(),
                        'batch': batchController.text.trim(),
                        'bio': bioController.text.trim(),
                        'profession': professionController.text.trim(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated successfully!')),
                      );

                      setState(() => isEditMode = false);
                    } catch (e) {
                      print('Update error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update: $e')),
                      );
                    }
                  },

                  child: Text('Save Data'),
                ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 4,
        onTap: _onNavTap,
        role: 'student',
      ),
    );
  }

  Widget buildEditableField(
      TextEditingController controller,
      bool editable, {
        String? label,
        double fontSize = 14,
        Color color = Colors.black,
        bool isCenter = false,
        String? placeholder,
        double? underlineWidth,
        bool hideUnderline = false,
      }) {
    return editable
        ? SizedBox(
      width: underlineWidth ?? (isCenter ? 120 : null),
      child: TextFormField(
        controller: controller,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: TextStyle(color: color, fontSize: fontSize),
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          hintStyle: TextStyle(color: color.withOpacity(0.5)),
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
      ),
    )
        : Text(
      controller.text.isEmpty ? (placeholder ?? '') : controller.text,
      textAlign: isCenter ? TextAlign.center : TextAlign.start,
      style: TextStyle(fontSize: fontSize, color: color.withOpacity(controller.text.isEmpty ? 0.5 : 1)),
    );
  }
}
