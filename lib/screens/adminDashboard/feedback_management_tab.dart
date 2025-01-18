import 'package:flutter/material.dart';

class FeedbackManagementTab extends StatelessWidget {
  const FeedbackManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Feedback management",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
