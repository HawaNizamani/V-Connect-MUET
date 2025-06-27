import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  // Dummy credentials - replace with your actual project values
  String projectId = "your-project-id";
  String clientEmail = "service-account@project.iam.gserviceaccount.com";
  String privateKey = "-----BEGIN PRIVATE KEY-----\\n...\\n-----END PRIVATE KEY-----\\n";
  String? accessToken;

  @override
  void initState() {
    super.initState();
    // TODO: Uncomment and implement token logic
    // loadServiceAccountAndAuthenticate();
  }

  Future<String?> sendToDialogflow(String message) async {
    // Dummy implementation: Replace this with your real API call
    await Future.delayed(const Duration(seconds: 1));
    return "This is a dummy bot reply to: $message";
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({"message": text, "isUser": true});
    });
    _controller.clear();

    final botReply = await sendToDialogflow(text);

    if (botReply != null) {
      setState(() {
        messages.add({"message": botReply, "isUser": false});
      });
    }
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    return Align(
      alignment: msg['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg['isUser'] ? Colors.brown[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['message'],
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF5D2D2B); // dark brown

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: const Icon(Icons.arrow_back),
        title: const Text('Chatbot'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        children: [
          // Bot avatar and welcome message
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 10),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: const AssetImage("assets/chatbot.png"), // Place your chatbot image here
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                Text(
                  "How can I help you ?",
                  style: TextStyle(
                    fontSize: 18,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) => buildMessage(messages[index]),
            ),
          ),
          const Divider(height: 1),
          Container(
            color: primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF5D2D2B)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Add icon tapped")),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D2D2B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF5D2D2B)),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
