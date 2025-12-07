import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_connect_muet/applied_opportunities_screen.dart';
import 'package:v_connect_muet/available_opportunities_screen.dart';
import 'package:v_connect_muet/chatbot_screen.dart';
import 'package:v_connect_muet/notification_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'bottom_navbar_student.dart';

class ProfileStudentScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isViewOnly; // 👈 Added view-only flag

  const ProfileStudentScreen({
    super.key,
    required this.userData,
    this.isViewOnly = false,
  });

  @override
  State<ProfileStudentScreen> createState() => _ProfileStudentScreenState();
}

class _ProfileStudentScreenState extends State<ProfileStudentScreen> {
  File? _profileImage;
  bool isEditMode = false;

  Future<void> signout() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to login screen after logout
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
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
    // Safely initialize profileImage
    widget.userData['profileImage'] = widget.userData.containsKey('profileImage')
        ? widget.userData['profileImage']
        : '';
    loadExperienceData();
  }

  // Inside _ProfileStudentScreenState

  Future<void> updateUserData() async {
    if (widget.isViewOnly) return;

    final uid = widget.userData['uid'] ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Build update map
      final update = <String, dynamic>{
        'name': nameController.text.trim(),
        'profession': professionController.text.trim(),
        'batch': batchController.text.trim(),
        'department': departmentController.text.trim(),
        'bio': bioController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(), // optional timestamp
      };

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set(update, SetOptions(merge: true));

      // Update local userData
      widget.userData.addAll(update);

      // ✅ Exit edit mode to return to view mode
      setState(() {
        isEditMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      debugPrint('⚠️ Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  List<Map<String, String>> experiences = [];

  void _pickProfileImage() async {
    if (widget.isViewOnly || !isEditMode) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _profileImage = File(picked.path));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      // ✅ Upload the file and wait until complete
      final uploadTask = ref.putFile(_profileImage!);
      final snapshot = await uploadTask.whenComplete(() {});

      // ✅ Make sure upload succeeded
      if (snapshot.state == TaskState.success) {
        // ✅ Get download URL safely
        final imageUrl = await ref.getDownloadURL();

        // ✅ Save URL in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileImage': imageUrl,
        });

        // ✅ Update local memory
        setState(() {
          widget.userData['profileImage'] = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated")),
        );
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
    }
  }

  void _toggleEdit() {
    if (widget.isViewOnly) return; // 👈 disable in view-only
    setState(() => isEditMode = true);
  }

  void _showPopupMenu() async {
    if (widget.isViewOnly) return; // 👈 disable in view-only
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
          child: const Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 6),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }

  void showAddExperienceDialog(BuildContext context) {
    if (widget.isViewOnly) return; // 👈 disable in view-only

    TextEditingController titleController = TextEditingController();
    TextEditingController companyController = TextEditingController();
    TextEditingController durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Experience'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company')),
            TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Duration')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final company = companyController.text.trim();
              final duration = durationController.text.trim();

              if (title.isEmpty || company.isEmpty || duration.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final uid = widget.userData['uid'] ?? FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              final newExp = {'title': title, 'company': company, 'duration': duration};
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              List<dynamic> currentExps = userDoc.data()?['experience'] ?? [];
              currentExps.add(newExp);

              await FirebaseFirestore.instance.collection('users').doc(uid).update({
                'experience': currentExps,
              });

              setState(() {
                experiences = List<Map<String, String>>.from(
                  currentExps.map((e) => Map<String, String>.from(e)),
                );
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Experience added')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void loadExperienceData() async {
    try {
      // 👇 Determine which user's data to load
      final uid = widget.isViewOnly
          ? widget.userData['uid'] // student's UID in view-only mode
          : FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) return;

      // ✅ Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data();

      // Safely update profileImage from Firestore
      widget.userData['profileImage'] = data?.containsKey('profileImage') == true
          ? data!['profileImage']
          : '';

      if (data != null && data.containsKey('experience')) {
        final expData = data['experience'] as List<dynamic>;

        setState(() {
          experiences = expData.map((e) => Map<String, String>.from(e as Map)).toList();
        });
      } else {
        setState(() => experiences = []);
      }
    } catch (e) {
      debugPrint('⚠️ Error loading experiences: $e');
    }
  }


  void _onNavTap(int index) async {
    if (index == 4) return; // already on profile
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AvailableOpportunitiesScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppliedOpportunitiesScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,

      // Hide Drawer for view-only
      drawer: widget.isViewOnly
          ? null
          : Drawer(
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
              onTap: signout,
            ),
          ],
        ),
      ),

      appBar: AppBar(
        automaticallyImplyLeading: !widget.isViewOnly,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 16,
        title: Text(
          widget.isViewOnly ? 'Student Profile' : 'Student Profile',
          style: const TextStyle(color: Colors.white),
        ),
        actions: widget.isViewOnly
            ? []
            : [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showPopupMenu,
          ),
        ],
      ),

      floatingActionButton: widget.isViewOnly
          ? null
          : FloatingActionButton(
        onPressed: () => showAddExperienceDialog(context),
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ Profile header
              Container(
                width: double.infinity,
                color: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: widget.isViewOnly || !isEditMode ? null : _pickProfileImage,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (widget.userData['profileImage'] != null
                            ? NetworkImage(widget.userData['profileImage'])
                            : null),
                        child: (_profileImage == null && widget.userData['profileImage'] == null)
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    isEditMode && !widget.isViewOnly
                        ? buildEditableField(
                      nameController,
                      true,
                      fontSize: 20,
                      color: Colors.white,
                      isCenter: true,
                      placeholder: "Name",
                      hideUnderline: false,
                    )
                        : Text(
                      nameController.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    isEditMode && !widget.isViewOnly
                        ? buildEditableField(
                      professionController,
                      true,
                      fontSize: 16,
                      color: Colors.white70,
                      isCenter: true,
                      placeholder: "Skill / Profession",
                    )
                        : Text(
                      professionController.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    isEditMode && !widget.isViewOnly
                        ? Column(
                      children: [
                        buildEditableField(
                          batchController,
                          true,
                          fontSize: 14,
                          color: Colors.white,
                          isCenter: true,
                          placeholder: "Batch",
                          hideUnderline: false,
                        ),
                        const SizedBox(height: 5),
                        buildEditableField(
                          departmentController,
                          true,
                          fontSize: 14,
                          color: Colors.white,
                          isCenter: true,
                          placeholder: "Department",
                          hideUnderline: false,
                        ),
                      ],
                    )
                        : Text(
                      '${batchController.text} | ${departmentController.text}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isEditMode && !widget.isViewOnly
                          ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: buildEditableField(
                          bioController,
                          true,
                          fontSize: 14,
                          color: Colors.white,
                          isCenter: true,
                          placeholder: "Bio",
                          hideUnderline: false,
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          bioController.text.isEmpty ? 'No bio available' : bioController.text,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Experience Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Experience',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (experiences.isEmpty)
                      const Text("No experience added yet"),
                    ...experiences.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> exp = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(exp['title'] ?? ''),
                          subtitle: Text('${exp['company'] ?? ''} | ${exp['duration'] ?? ''}'),
                          trailing: widget.isViewOnly
                              ? null
                              : IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() => experiences.removeAt(index));
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.userData['uid'])
                                  .update({'experience': experiences});
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (isEditMode && !widget.isViewOnly)
                ElevatedButton(
                  onPressed: updateUserData,
                  child: const Text('Save Data'),
                ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: widget.isViewOnly
          ? null
          : StudentNavbar(currentIndex: 4, onTap: _onNavTap),
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
      style: TextStyle(
        fontSize: fontSize,
        color: color.withOpacity(controller.text.isEmpty ? 0.5 : 1),
      ),
    );
  }
}
