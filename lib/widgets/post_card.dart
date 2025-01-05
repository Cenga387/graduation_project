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
  String category = '';
  int upvotes = 0;
  int downvotes = 0;
  String? userVote;
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
          .select('title, description, category')
          .eq('id', widget.postId)
          .single();

      setState(() {
        title = response['title'];
        description = response['description'];
        category = response['category'];
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

  Future<void> _handleVote(String voteType) async {
    try {
      final supabase = Supabase.instance.client;

      if (voteType == userVote) {
        // Cancel the vote
        final field = voteType == 'upvote' ? 'upvotes' : 'downvotes';
        await supabase
            .from('posts')
            .update({field: field == 'upvotes' ? upvotes - 1 : downvotes - 1})
            .eq('id', widget.postId);

              setState(() {
          if (voteType == 'upvote') {
            upvotes--;
          } else {
            downvotes--;
          }
          userVote = null;
        });
      } else {
        // Update the vote
        final field = voteType == 'upvote' ? 'upvotes' : 'downvotes';
        // If switching vote, cancel the previous vote first
        if (userVote != null) {
          final previousField = userVote == 'upvote' ? 'upvotes' : 'downvotes';
          await supabase
              .from('posts')
              .update({previousField: previousField == 'upvotes' ? upvotes - 1 : downvotes - 1})
              .eq('id', widget.postId);
          setState(() {
            if (userVote == 'upvote') {
              upvotes--;
            } else {
              downvotes--;
            }
          });
        }
          await supabase
            .from('posts')
            .update({field: field == 'upvotes' ? upvotes + 1 : downvotes + 1})
            .eq('id', widget.postId);
        setState(() {
          if (voteType == 'upvote') {
            upvotes++;
          } else {
            downvotes++;
          }
          userVote = voteType;
        });
      }
      
    } catch (e) {
      debugPrint('Error handling votes: $e');
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
                      icon: Icon(
                        Icons.arrow_upward,
                        color: userVote == 'upvote' ? Colors.green : Colors.white,
                      ),
                      onPressed: () => _handleVote('upvote'),
                    ),
                    Text(
                      '${upvotes - downvotes}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_downward,
                        color: userVote == 'downvote' ? Colors.red : Colors.white,
                      ),
                      onPressed: () => _handleVote('downvote'),
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
                    style: TextStyle(color: Color(0xFF005597)),
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
