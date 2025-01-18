import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AnnouncementPageState();
  }
}

class _AnnouncementPageState extends State<AnnouncementPage> {
List<dynamic> posts = [];
String? _selectedFaculty;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPostsByFaculty('All');
  }
// Fetch posts for a specific faculty
  Future<void> _fetchPostsByFaculty(String faculty) async {
    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('posts')
          .select()
          .eq('faculty', faculty)
          .order('created_at', ascending: false);

      setState(() {
        posts = response as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      setState(() => isLoading = false);
    }
  }
  // Handle faculty button click
  void _onFacultyButtonPressed(String faculty) {
    if (_selectedFaculty == faculty) {
      // Reset to 'All' posts if the same faculty is clicked again
      setState(() => _selectedFaculty = null);
      _fetchPostsByFaculty('All');
    } else {
      // Highlight the new faculty and fetch its posts
      setState(() => _selectedFaculty = faculty);
      _fetchPostsByFaculty(faculty);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Faculty Filter Options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 44,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMenuIcon(
                    label: 'FENS', isSelected: _selectedFaculty == 'FENS', onTap: () => _onFacultyButtonPressed('FENS')),
                _buildMenuIcon(
                    label: 'FLW', isSelected: _selectedFaculty == 'FLW', onTap: () => _onFacultyButtonPressed('FLW')),
                _buildMenuIcon(
                    label: 'FASS', isSelected: _selectedFaculty == 'FASS', onTap: () => _onFacultyButtonPressed('FASS')),
                _buildMenuIcon(
                    label: 'FBA', isSelected: _selectedFaculty == 'FBA', onTap: () => _onFacultyButtonPressed('FBA')),
                _buildMenuIcon(
                    label: 'FEDU', isSelected: _selectedFaculty == 'FEDU', onTap: () => _onFacultyButtonPressed('FEDU')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Display Filtered Posts
          Expanded(
            child: posts.isEmpty
                ? const Center(
                    child: Text('No posts available for this faculty.'),
                  )
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(postId: post['id'].toString());
                    },
                  ),
          ),
        ],
      ),
    );
  }

Widget _buildMenuIcon({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color.fromARGB(255, 0, 102, 181) : const Color(0xFF005597),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color:   Color(0xFF005597),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2), // Shadow position
                  ),
                ]
              : [],
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
