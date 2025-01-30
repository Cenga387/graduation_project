import 'package:flutter/material.dart';
import 'package:graduation_project/screens/create_post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/nav_bar.dart';
import 'home.dart';
import 'announcements.dart';
import 'careers.dart';
import 'profile.dart';
import 'posts_list_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: _scaffoldKey, // Assign the key to the Scaffold
      drawer: _titles[_selectedIndex] == "Announcements"
          ? Drawer(
              child: ListView(
                children: [
                  const SizedBox(
                    height: 100,
                    child: DrawerHeader(
                      decoration: BoxDecoration(color: Color(0xFF005597)),
                      child: Text(
                        'Menu',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                  _buildDrawerItem(context, 'Announcement (General)', 'General'),
                  _buildDrawerItem(context, 'Announcement (IRO)', 'IRO'),
                  _buildDrawerItem(context, 'Announcement (SAO)', 'SAO'),
                  _buildDrawerItem(context, 'Announcement (SCC)', 'SCC'),
                  _buildDrawerItem(context, 'Announcement (IUS Wolves)', 'IUS Wolves'),
                  _buildDrawerItem(context, 'Event', 'Event'),
                  _buildDrawerItem(context, 'Job', 'Job'),
                  _buildDrawerItem(context, 'Internship', 'Internship'),
                  _buildDrawerItem(context, 'Erasmus', 'Erasmus'),
                  _buildDrawerItem(context, 'Clubs', 'Clubs'),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        leading: _titles[_selectedIndex] == "Announcements"
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState
                      ?.openDrawer(); // Access ScaffoldState
                },
              )
            : null,
        actions: [
          if (_selectedIndex == 0 &&
              _userRole ==
                  'admin') // Add '+' button for admins on the Home page
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

  Widget _buildDrawerItem(BuildContext context, String category, String title) {
    return ListTile(
      minTileHeight: 50,
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostsListPage(category: category),
          ),
        );
      },
    );
  }
}
