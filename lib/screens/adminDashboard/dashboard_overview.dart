import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardOverviewTab extends StatefulWidget {
  const DashboardOverviewTab({super.key});

  @override
  State<DashboardOverviewTab> createState() => _DashboardOverviewTabState();
}

class _DashboardOverviewTabState extends State<DashboardOverviewTab> {
  bool isLoading = true;
  int totalPosts = 0;
  int totalUsers = 0;
  int activeEvents = 0;
  List<dynamic> recentFeedback = [];

  @override
  void initState() {
    super.initState();
    _fetchOverviewData();
  }

  Future<void> _fetchOverviewData() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch total posts
      final totalPostsResponse = await supabase.from('posts').select('*');
      // Fetch total users
      final totalUsersResponse = await supabase.from('profile').select('*');
      // Fetch active events
      final activeEventsResponse =
          await supabase.from('posts').select().eq('category', 'Event');
      // Fetch recent feedback
      final recentFeedbackResponse = await supabase
          .from('feedback')
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      setState(() {
        totalPosts = totalPostsResponse.length;
        totalUsers = totalUsersResponse.length;
        activeEvents = activeEventsResponse.length;
        recentFeedback = recentFeedbackResponse as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
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
        _buildOverviewCard("Total Posts", totalPosts),
        _buildOverviewCard("Total Users", totalUsers),
        _buildOverviewCard("Active Events", activeEvents),
        const SizedBox(height: 24),
        const Text(
          "Recent Feedback",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (recentFeedback.isEmpty)
          const Center(child: Text("No feedback available.")),
        ...recentFeedback.map((feedback) {
          return ListTile(
            title: Text(feedback['content']),
            subtitle: Text("From: ${feedback['user_email']}"),
          );
        }),
      ],
    );
  }

  Widget _buildOverviewCard(String title, int value) {
    return Card(
      color: const Color(0xFF005597),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Text(
          value.toString(),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
