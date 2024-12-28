import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graduation_project/widgets/post_card.dart';

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
              ),
            ),
            // Jobs Section
            if (categorizedPosts.containsKey('jobs'))
              _buildSection(context, 'Jobs', 'jobs'),

            // Internships Section
            if (categorizedPosts.containsKey('internship'))
              _buildSection(context, 'Internships', 'internship'),

            // Events Section
            if (categorizedPosts.containsKey('event'))
              _buildSection(context, 'Events', 'event'),
          ],
        ),
      ),
    );
  }

  // Widget _buildMenuIcon({
  //   required String iconPath,
  //   required String label,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       children: [
  //         CircleAvatar(
  //           radius: 30,
  //           backgroundImage: AssetImage(iconPath),
  //         ),
  //         const SizedBox(height: 4),
  //         Flexible(
  //           child: Text(
  //             label,
  //             textAlign: TextAlign.center,
  //             style: const TextStyle(fontSize: 12),
  //             maxLines: 2,
  //             overflow: TextOverflow.visible,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
