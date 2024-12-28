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
  Map<String, List<String>> categorizedPosts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('posts').select('id, category');

      final data = response as List<dynamic>;

      final Map<String, List<String>> postsByCategory = {};
      for (var post in data) {
        final String category = post['category'];
        final int postId = post['id'];

        if (!postsByCategory.containsKey(category)) {
          postsByCategory[category] = [];
        }
        postsByCategory[category]?.add(postId.toString());
      }

      setState(() {
        categorizedPosts = postsByCategory;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      setState(() {
        isLoading = false;
      });
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      label: 'FENS', onTap: () => {debugPrint('FENS clicked')}),
                  _buildMenuIcon(
                      label: 'FLW', onTap: () => {debugPrint('FLW clicked')}),
                  _buildMenuIcon(
                      label: 'FASS', onTap: () => {debugPrint('FASS clicked')}),
                  _buildMenuIcon(
                      label: 'FBA', onTap: () => {debugPrint('FBA clicked')}),
                  _buildMenuIcon(
                      label: 'FEDU', onTap: () => {debugPrint('FEDU clicked')}),
                ],
              ),
            ),
            // Announcements Section
            if (categorizedPosts.containsKey('announcement'))
              _buildSection(context, 'Announcements', 'announcement'),

            // Events Section
            if (categorizedPosts.containsKey('event'))
              _buildSection(context, 'Events', 'event'),

            // Other Categories (Add as Needed)
            if (categorizedPosts.containsKey('internship'))
              _buildSection(context, 'Internships', 'internship'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF005597),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String category) {
    final posts = categorizedPosts[category] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  // Navigate to full list of posts for this category
                },
              ),
            ],
          ),
        ),
        // Post Cards
        ...posts.map((postId) => PostCard(postId: postId)),
      ],
    );
  }
}
