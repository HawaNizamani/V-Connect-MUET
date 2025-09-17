import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_connect_muet/applied_opportunities_screen.dart';
import 'package:v_connect_muet/available_opportunities_screen.dart';
import 'package:v_connect_muet/chatbot_screen.dart';
import 'package:v_connect_muet/notification_screen.dart';
import 'bottom_navbar_student.dart';

class ProfileStudentScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileStudentScreen({super.key, required this.userData});

  @override
  State<ProfileStudentScreen> createState() => _ProfileStudentScreenState();
}

class _ProfileStudentScreenState extends State<ProfileStudentScreen> {
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

    loadExperienceData();
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

  List<Map<String, String>> experiences = [];

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

  void showAddExperienceDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController companyController = TextEditingController();
    TextEditingController durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Experience'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: companyController, decoration: InputDecoration(labelText: 'Company')),
            TextField(controller: durationController, decoration: InputDecoration(labelText: 'Duration')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final String title = titleController.text.trim();
              final String company = companyController.text.trim();
              final String duration = durationController.text.trim();

              if (title.isEmpty || company.isEmpty || duration.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final uid = widget.userData['uid'] ?? FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User ID not found.')),
                );
                return;
              }

              final newExp = {
                'title': title,
                'company': company,
                'duration': duration,
              };

              try {
                final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                List<dynamic> currentExps = userDoc.data()?['experience'] ?? [];

                currentExps.add(newExp);

                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'experience': currentExps,
                });

                // Update local state to reflect UI immediately
                setState(() {
                  experiences = List<Map<String, String>>.from(
                    currentExps.map((e) => Map<String, String>.from(e)),
                  );
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Experience added')),
                );
              } catch (e) {
                print('Error saving experience: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save experience: $e')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }


  void deleteExperience(int index) async {
    String uid = widget.userData['uid'];

    setState(() {
      experiences.removeAt(index);
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'experience': experiences,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Experience deleted')),
    );
  }

  void loadExperienceData() async {
    final uid = widget.userData['uid'] ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('No UID found');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data();
      if (data != null && data.containsKey('experience')) {
        final expData = data['experience'] as List<dynamic>;

        setState(() {
          experiences = expData
              .map((e) => Map<String, String>.from(e as Map))
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching experience data: $e');
    }
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
                builder: (_) => NotificationScreen(),
              ),
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

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0A1D56)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.grey, size: 40),
              ),
              accountName: Text(widget.userData['name'] ?? 'No Name'),
              accountEmail: Text(widget.userData['email'] ?? 'No Email'),
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
              onTap: signout
            ),
          ],
        ),
      ),


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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white,),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddExperienceDialog(context);
        },
        child: Icon(Icons.add),
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

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...experiences.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> exp = entry.value;

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(exp['title'] ?? ''),
                          subtitle: Text('${exp['company'] ?? ''} | ${exp['duration'] ?? ''}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              final uid = widget.userData['uid'] ?? FirebaseAuth.instance.currentUser?.uid;
                              if (uid == null) {
                                print('No UID found');
                                return;
                              }

                              // Get the item to be deleted
                              final itemToDelete = experiences[index];

                              try {
                                // Remove from Firestore
                                final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
                                final snapshot = await userDocRef.get();
                                final currentData = snapshot.data();

                                if (currentData != null && currentData.containsKey('experience')) {
                                  List<dynamic> currentExperience = currentData['experience'];

                                  // Remove the item from the list
                                  currentExperience.removeWhere((item) =>
                                  item['title'] == itemToDelete['title'] &&
                                      item['organization'] == itemToDelete['organization'] &&
                                      item['duration'] == itemToDelete['duration']);

                                  // Update Firestore
                                  await userDocRef.update({'experience': currentExperience});
                                }

                                // Remove from local UI list
                                setState(() {
                                  experiences.removeAt(index);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Experience deleted')),
                                );
                              } catch (e) {
                                print('Delete error: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete experience')),
                                );
                              }
                            },
                          )

                        ),
                      );
                    }).toList(),
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
        bottomNavigationBar: StudentNavbar(
            currentIndex: 4,
            onTap: _onNavTap
        )
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
