import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

import 'applications_screen.dart';
import 'applied_opportunities_screen.dart';
import 'available_opportunities_screen.dart';
import 'bottom_navbar_organization.dart';
import 'bottom_navbar_student.dart';
import 'dashboard_screen.dart';
import 'notification_screen.dart';
import 'profile_organization_screen.dart';
import 'profile_student_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  // ✅ Send message to Dialogflow using service account
  Future<String> _sendToDialogflow(String query) async {
    // Load credentials from assets
    final serviceAccount = jsonDecode(await rootBundle
        .loadString('assets/credentials/v-connect-muet-cf44b-92a0bc379a2f.json'));

    final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

    // Generate authenticated client
    final client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    final projectId = serviceAccount['project_id'];
    final apiUrl =
        'https://dialogflow.googleapis.com/v2/projects/v-connect-muet-cf44b/agent/sessions/123456789:detectIntent';

    final response = await client.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        "queryInput": {
          "text": {"text": query, "languageCode": "en"}
        }
      }),
    );

    final body = jsonDecode(response.body);
    client.close();

    if (body['queryResult'] != null) {
      return body['queryResult']['fulfillmentText'] ?? "Sorry, I didn’t get that.";
    } else {
      return "Error: ${body['error']?['message'] ?? 'Unknown error.'}";
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isSending = true;
    });
    _controller.clear();

    try {
      final reply = await _sendToDialogflow(text);
      setState(() {
        _messages.add({'sender': 'bot', 'text': reply});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'Error connecting to chatbot. Please try again later.'
        });
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<String?> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role']; // "student" or "organization"
  }

  void _onNavTap(String role, int index) async {
    if (index == 2) return; // already on chatbot

    if (role == 'organization') {
      switch (index) {
        case 0:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()));
          break;
        case 1:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ApplicationsScreen()));
          break;
        case 3:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()));
          break;
        case 4:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => ProfileOrganizationScreen()));
          break;
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const AvailableOpportunitiesScreen()));
          break;
        case 1:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const AppliedOpportunitiesScreen()));
          break;
        case 3:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()));
          break;
        case 4:
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
            if (!mounted) return;
            final userData = doc.data();
            if (userData != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileStudentScreen(userData: userData)),
              );
            }
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF0A1D56);

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
          backgroundColor: const Color(0xFFF5F9FF),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Chatbot',
              style: TextStyle(color: primary, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 1,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "How can I help you?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['sender'] == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin:
                          const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? primary.withOpacity(0.9)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color:
                              isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      _isSending
                          ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child:
                            CircularProgressIndicator(strokeWidth: 2)),
                      )
                          : IconButton(
                        icon:
                        const Icon(Icons.send, color: primary),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: role == 'student'
              ? StudentNavbar(
            currentIndex: 2,
            onTap: (index) => _onNavTap('student', index),
          )
              : OrganizationNavbar(
            currentIndex: 2,
            onTap: (index) => _onNavTap('organization', index),
          ),
        );
      },
    );
  }
}
