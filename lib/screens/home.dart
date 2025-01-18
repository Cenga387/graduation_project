import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'posts_list_page.dart';

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

  _launchURL() async {
    final Uri url = Uri.parse('https://www.ius.edu.ba/en/academic-calendar');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _fetchPosts() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch posts from the database
      final response = await supabase.from('posts').select('id, category');

      final data = response as List<dynamic>;

      // Group posts by category with filtering for 'Announcement'
      final Map<String, List<String>> postsByCategory = {};
      for (var post in data) {
        final String category = post['category'];
        final int postId = post['id'];

        // Group 'Announcement' posts under a common key
        final categoryKey =
            category.contains('Announcement') ? 'Announcement' : category;

        if (!postsByCategory.containsKey(categoryKey)) {
          postsByCategory[categoryKey] = [];
        }

        postsByCategory[categoryKey]!.add(postId.toString());
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
      child: SingleChildScrollView(
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
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostsListPage(
                              category: 'Announcement (IUS Wolves)'),
                        ),
                      )
                    },
                  ),
                  _buildMenuIcon(
                    iconPath: 'assets/erasmus.png',
                    label: 'Erasmus',
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PostsListPage(category: 'Erasmus'),
                        ),
                      )
                    },
                  ),
                  _buildMenuIcon(
                    iconPath: 'assets/internships.jpg',
                    label: 'Internships',
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PostsListPage(category: 'Internship'),
                        ),
                      )
                    },
                  ),
                  _buildMenuIcon(
                    iconPath: 'assets/calendar.png',
                    label: 'Academic Calendar',
                    onTap: () => _launchURL(),
                  ),
                  _buildMenuIcon(
                    iconPath: 'assets/iro.jpeg',
                    label: 'IRO',
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostsListPage(
                              category: 'Announcement (IRO)'),
                        ),
                      )
                    },
                  ),
                  _buildMenuIcon(
                    iconPath: 'assets/ius-logo.png',
                    label: 'SAO',
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostsListPage(
                              category: 'Announcement (SAO)'),
                        ),
                      )
                    },
                  ),
                  _buildMenuIcon(
                    iconPath: 'assets/scc.jpeg',
                    label: 'SCC',
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostsListPage(
                              category: 'Announcement (SCC)'),
                        ),
                      )
                    },
                  ),
                  _buildMenuIcon(
                    iconPath: 'assets/clubs.jpg',
                    label: 'Clubs',
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PostsListPage(category: 'Clubs'),
                        ),
                      )
                    },
                  ),
                ],
              ),
            ),
            // Announcements Section
            if (categorizedPosts.containsKey('Announcement'))
              _buildSection(context, 'Announcements', 'Announcement'),

            // Events Section
            if (categorizedPosts.containsKey('Event'))
              _buildSection(context, 'Events', 'Event'),

            // Other Categories (Add as Needed)
            if (categorizedPosts.containsKey('Internship'))
              _buildSection(context, 'Internships', 'Internship'),
          ],
        ),
      ),
    ));
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

  Widget _buildSection(BuildContext context, String title, String category) {
    final posts = categorizedPosts[category] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        isAnnouncement: category == 'Announcement',
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
