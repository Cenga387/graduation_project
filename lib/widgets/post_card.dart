import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graduation_project/screens/detailed_post.dart';

class PostCard extends StatefulWidget {
  final String postId;

  const PostCard({
    super.key,
    required this.postId,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String title = '';
  String description = '';
  int upvotes = 0;
  int downvotes = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPost();
    _fetchVotes();
  }

  Future<void> _fetchPost() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('posts')
          .select('title, description') // Use correct column names
          .eq('id', widget.postId)
          .single();

      setState(() {
        title = response['title'];
        description = response['description'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching post details: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchVotes() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('posts')
          .select('upvotes, downvotes')
          .eq('id', widget.postId)
          .single();

      setState(() {
        upvotes = response['upvotes'];
        downvotes = response['downvotes'];
      });
    } catch (e) {
      debugPrint('Error fetching votes: $e');
    }
  }

  Future<void> _updateVote(bool isUpvote) async {
    try {
      final supabase = Supabase.instance.client;
      final field = isUpvote ? 'upvotes' : 'downvotes';

      // Update the database
      await supabase
          .from('posts')
          .update({field: isUpvote ? upvotes + 1 : downvotes + 1}).eq(
              'id', widget.postId);

      // Update the local state
      setState(() {
        if (isUpvote) {
          upvotes++;
        } else {
          downvotes++;
        }
      });
    } catch (e) {
      debugPrint('Error updating votes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      color: const Color(0xFF005597),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Upvote and Downvote buttons with score
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: () => _updateVote(true),
                    ),
                    Text(
                      '${upvotes - downvotes}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_downward, color: Colors.white),
                      onPressed: () => _updateVote(false),
                    ),
                  ],
                ),
                // Show More Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailedPostScreen(postId: widget.postId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Show more',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
