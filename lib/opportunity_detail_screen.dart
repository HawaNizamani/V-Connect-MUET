import 'package:flutter/material.dart';

class OpportunityDetailScreen extends StatelessWidget {
  const OpportunityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Opportunity Details"),
        backgroundColor: const Color(0xFF5D3A3A),
      ),
      body: const Center(
        child: Text("Full opportunity details here."),
      ),
    );
  }
}
