import 'package:flutter/material.dart';
import 'package:graduation_project/screens/create_post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/nav_bar.dart';
import 'home.dart';
import 'announcements.dart';
import 'careers.dart';
import 'profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final _homeScreen = const HomePage();
  final _announcementScreen = const AnnouncementPage();
  final _careersScreen = const CareersPage();
  final _profileScreen = const ProfilePage();

  late final List<Widget> _screens;

  final List<String> _titles = [
    'Home',
    'Announcements',
    'Careers',
    'Profile',
  ];

  String? _userRole; // Store the user's role

  @override
  void initState() {
    super.initState();
    _fetchUserRole(); // Fetch the user role during initialization
    _screens = [
      _homeScreen,
      _announcementScreen,
      _careersScreen,
      _profileScreen,
    ];
  }

  Future<void> _fetchUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await Supabase.instance.client
          .from('profile')
          .select('role')
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userRole = response['role']; // Assign the role to the variable
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        actions: [
          if (_selectedIndex == 0 && _userRole == 'admin') // Add '+' button for admins on the Home page
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
