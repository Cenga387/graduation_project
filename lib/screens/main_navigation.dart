import 'package:flutter/material.dart';
import 'package:graduation_project/screens/create_post.dart';
import 'package:graduation_project/screens/section.dart';
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

  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
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
          _userRole = response['role'];
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
      key: _scaffoldKey,
      drawer: _titles[_selectedIndex] == "Announcements"
          ? Drawer(
              child: ListView(
                children: [
                  Container(
                    height: 80,
                    color: Colors.blue,
                    child: const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Text(
                        'Menu',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Internships'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SectionPage(
                            title: 'Interships',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Exams'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SectionPage(
                            title: 'Exams',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Erasmus'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SectionPage(
                            title: 'Erasmus',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Volunteering'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SectionPage(
                            title: 'Volunteering',
                          ),
                        ),
                      );
                    },
                  ),
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
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : null,
        actions: [
          if (_selectedIndex == 0 && _userRole == 'admin')
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
