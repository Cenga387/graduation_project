import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostsListPage extends StatefulWidget {
  final String category;
  final bool isAnnouncement;

  const PostsListPage(
      {super.key, required this.category, this.isAnnouncement = false});

  @override
  State<PostsListPage> createState() => _PostsListPageState();
}

class _PostsListPageState extends State<PostsListPage> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPostsByCategory();
  }

  Future<void> _fetchPostsByCategory() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch posts with appropriate filtering
      final response = widget.isAnnouncement
          ? await supabase.from('posts').select().ilike('category',
              '%Announcement%') // Filter posts containing "Announcement"
          : await supabase
              .from('posts')
              .select()
              .eq('category', widget.category);

      setState(() {
        posts = response as List<dynamic>;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} posts'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(
                  child: Text('No posts available for this category.'))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(postId: post['id'].toString());
                  },
                ),
    );
  }
}
