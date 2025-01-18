import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graduation_project/widgets/post_card.dart';
import 'posts_list_page.dart';

class CareersPage extends StatefulWidget {
  const CareersPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CareersPageState();
  }
}

class _CareersPageState extends State<CareersPage> {
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

      // Fetch posts from the database
      final response = await supabase.from('posts').select('id, category');
      final data = response as List<dynamic>;

      // Group posts by category without special filtering for announcements
      final Map<String, List<String>> postsByCategory = {};
      for (var post in data) {
        final String category = post['category'];
        final int postId = post['id'];

        if (!postsByCategory.containsKey(category)) {
          postsByCategory[category] = [];
        }

        postsByCategory[category]!.add(postId.toString());
      }

      // Update state with the categorized posts
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

  Future<void> _refreshPosts() async {
    setState(() {
      isLoading = true;
    });

    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        body: RefreshIndicator(
      onRefresh: _refreshPosts,
      child: ListView(
          children: [
            // Job Section
            if (categorizedPosts.containsKey('Job'))
              _buildSection(context, 'Job', 'Job'),
            const SizedBox(height: 16.0),
            // Events Section
            if (categorizedPosts.containsKey('Erasmus'))
              _buildSection(context, 'Erasmus', 'Erasmus'),
            const SizedBox(height: 16.0),
            // Internships Section
            if (categorizedPosts.containsKey('Internship'))
              _buildSection(context, 'Internships', 'Internship'),
          ],
        ),
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
                  // Navigate to PostsListPage with appropriate category filtering
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostsListPage(
                        category: category,
                        isAnnouncement:
                            false, // No special filtering for announcements
                      ),
                    ),
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
