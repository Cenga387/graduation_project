import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
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

      // Group posts by category
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
                crossAxisCount: 4,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 24,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMenuIcon(
                      iconPath: 'assets/ius_wolves.jpeg',
                      label: 'IUS Wolves',
                      onTap: () => {debugPrint('IUS wolves clicked')}),
                  _buildMenuIcon(
                      iconPath: 'assets/erasmus.png',
                      label: 'Erasmus',
                      onTap: () => {debugPrint('Erasmus clicked')}),
                  _buildMenuIcon(
                      iconPath: 'assets/internships.jpg',
                      label: 'Internships',
                      onTap: () => {debugPrint('Internships clicked')}),
                  _buildMenuIcon(
                      iconPath: 'assets/calendar.png',
                      label: 'Academic Calendar',
                      onTap: () => {debugPrint('Academic Calendar clicked')}),
                  _buildMenuIcon(
                      iconPath: 'assets/iro.jpeg',
                      label: 'IRO',
                      onTap: () => {debugPrint('IRO clicked')}),
                  _buildMenuIcon(
                      iconPath: 'assets/ius-logo.png',
                      label: 'SAO',
                      onTap: () => {debugPrint('SAO clicked')}),
                  _buildMenuIcon(
                      iconPath: 'assets/scc.jpeg',
                      label: 'SCC',
                      onTap: () => {debugPrint('SCC clicked')}),
                  _buildMenuIcon(
                      iconPath: 'assets/clubs.jpg',
                      label: 'Clubs',
                      onTap: () => {debugPrint('Clubs clicked')}),
                ],
              ),
            ),
            // Announcements Section
            if (categorizedPosts.containsKey('Announcement'))
              _buildSection(
                  context, 'Announcements', 'Announcement', '/announcements'),

            // Events Section
            if (categorizedPosts.containsKey('Event'))
              _buildSection(context, 'Events', 'Event', '/events'),

            // Other Categories (Add as Needed)
            if (categorizedPosts.containsKey('Internship'))
              _buildSection(
                  context, 'Internships', 'Internship', '/internships'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(iconPath),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, String category, String route) {
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
                  Navigator.pushNamed(
                    context,
                    route,
                  );
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
