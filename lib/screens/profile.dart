import 'package:flutter/material.dart';
import 'package:graduation_project/screens/adminDashboard/admin_dashboard.dart.dart';
import 'package:graduation_project/screens/inbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graduation_project/screens/feedback.dart';
import 'package:graduation_project/screens/my_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userRole;
  String? _username;
  String? _faculty;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    // Clean up any resources here
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      // Fetch all required user data
      final response = await Supabase.instance.client
          .from('profile')
          .select('role, username, faculty')
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userRole = response['role'] as String?;
          _username = response['username'] as String?;
          _faculty = response['faculty'] as String?;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching user data: $e")),
        );
      }
    }
  }

Future<void> _signOut(BuildContext context) async {
  try {
    // Sign out the user
    await Supabase.instance.client.auth.signOut();

    // Navigate to the login screen if the widget is still mounted
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  } catch (e) {
    // Handle any errors during sign-out
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during sign-out: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  //backgroundImage: AssetImage('assets/oliver.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  _username ?? 'Guest user',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, size: 18, color: Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      Supabase.instance.client.auth.currentUser?.email ??
                          'No email',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _faculty ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Divider(thickness: 0.5, color: Colors.grey),
          Expanded(
            child: ListView(
              children: [
                if (_userRole == 'admin')
                  _buildProfileOption(
                    icon: Icons.admin_panel_settings,
                    text: 'Admin Dashboard',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboardPage(),
                        ),
                      );
                    },
                  ),
                _buildProfileOption(
                  icon: Icons.notifications,
                  text: 'Notifications',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.inbox,
                  text: 'Inbox',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InboxScreen()
                      )
                    );},
                ),
                if (_userRole == 'user')
                _buildProfileOption(
                  icon: Icons.event,
                  text: 'My events',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyEventsScreen()
                      )
                    );
                  },
                ),
                if (_userRole == 'user')
                  _buildProfileOption(
                    icon: Icons.feedback,
                    text: 'Feedback',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackScreen(),
                        ),
                      );
                    },
                  ),
                _buildProfileOption(
                  icon: Icons.logout,
                  text: 'Log out',
                  onTap: () {
                    _signOut(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 24),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}
