import 'package:flutter/material.dart';
import 'dashboard_overview.dart';
import 'user_management_tab.dart';
import 'feedback_management_tab.dart';
import 'analytics_tab.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedTabIndex = 0;

  final List<Widget> _tabs = [
    const DashboardOverviewTab(),
    const UserManagementTab(),
    const FeedbackManagementTab(),
    const AnalyticsTab(),
  ];

  final List<String> _tabTitles = [
    "Dashboard Overview",
    "User Management",
    "Feedback Management",
    "Analytics",
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    Navigator.pop(context); // Close the drawer after selecting a tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_selectedTabIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 150,
            child: DrawerHeader(
              
              decoration: BoxDecoration(
                color: Color(0xFF005597),
              ),
              child: Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard,
              text: "Dashboard Overview",
              index: 0,
            ),
            _buildDrawerItem(
              icon: Icons.people,
              text: "User Management",
              index: 1,
            ),
            _buildDrawerItem(
              icon: Icons.feedback,
              text: "Feedback Management",
              index: 2,
            ),
            _buildDrawerItem(
              icon: Icons.analytics,
              text: "Analytics",
              index: 3,
            ),
          ],
        ),
      ),
      body: _tabs[_selectedTabIndex],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      selected: _selectedTabIndex == index,
      onTap: () => _onTabSelected(index),
    );
  }
}
