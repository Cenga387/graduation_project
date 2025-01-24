import 'package:flutter/material.dart';
import 'package:graduation_project/screens/adminDashboard/charts/user_growth.dart';
import 'package:graduation_project/screens/adminDashboard/charts/faculty_dist.dart';
import 'package:graduation_project/screens/adminDashboard/charts/posts_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  bool isLoading = true;
  int totalPosts = 0;
  int totalUsers = 0;
  int activeEvents = 0;
  double cumulativeAttendancePercentage = 0.0;

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

      // Fetch potential attendance and attendance counts
      final potentialAttendanceResponse =
          await supabase.from('potential_attendance').select('id');
      final actualAttendanceResponse =
          await supabase.from('attendance').select('id');

      // Calculate attendance percentage
      final double totalPotentialAttendance = potentialAttendanceResponse.length.toDouble();
      final double totalActualAttendance = actualAttendanceResponse.length.toDouble();
      final double attendancePercentage = totalPotentialAttendance > 0
          ? (totalActualAttendance / totalPotentialAttendance) * 100
          : 0;

      setState(() {
        totalPosts = totalPostsResponse.length;
        totalUsers = totalUsersResponse.length;
        activeEvents = activeEventsResponse.length;
        cumulativeAttendancePercentage = attendancePercentage;
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
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard('Total Users', totalUsers),
            _buildCard('Total Posts', totalPosts),
            _buildCard('Active Events', activeEvents),
            _buildCard(
              'Attendance Percentage',
              cumulativeAttendancePercentage,
              isPercentage: true,
            ),
            const SizedBox(height: 32),
            const Text(
              "Total Users Over Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 300, // Height for the chart
              child: UserGrowthChart(), // UserGrowthChart widget
            ),
            const SizedBox(height: 32),
            const Text(
              'Faculty Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 300, child: FacultyDistributionWidget()),
            const Text(
              "Number of posts per category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 400,
              child: PostCategoryPieChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, dynamic value, {bool isPercentage = false}) {
    return Card(
      color: const Color(0xFF005597),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Text(
          isPercentage ? '${value.toStringAsFixed(2)}%' : value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
