import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackManagementTab extends StatefulWidget {
  const FeedbackManagementTab({super.key});

  @override
  State<FeedbackManagementTab> createState() => _FeedbackManagementTabState();
}

class _FeedbackManagementTabState extends State<FeedbackManagementTab> {
  List<dynamic> feedback = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeedbackData();
  }

  Future<void> _fetchFeedbackData() async {
    try {
      // Fetch feedback data
      final response = await Supabase.instance.client
          .from('feedback')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        feedback = response as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching feedback data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 24),
        if (feedback.isEmpty)
          const Center(child: Text("No feedback available.")),
        ...feedback.map((feedback) {
          return ListTile(
            title: Text(feedback['content']),
            subtitle: Text("From: ${feedback['user_email']}"),
          );
        }),
      ]
    );
  }
}
