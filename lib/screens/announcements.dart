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
  List<int> postIds = []; // List to store post IDs
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('posts').select('id');

      final data = response as List<dynamic>;

      // Extract post IDs from the response
      final List<int> fetchedPostIds =
          data.map((post) => post['id'] as int).toList();

      setState(() {
        postIds = fetchedPostIds;
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
            ...postIds.map((postId) => PostCard(postId: postId.toString())),
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
}
