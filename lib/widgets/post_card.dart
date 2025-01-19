import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graduation_project/screens/detailed_post.dart';
import 'package:graduation_project/screens/edit_post.dart';

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
  String? _userRole; // Store the user's role

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _fetchPost();
    _fetchVotes();
  }

  Future<void> _fetchUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await Supabase.instance.client
          .from('profile')
          .select('role')
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userRole = response['role']; // Assign the role to the variable
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _deletePost(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        await Supabase.instance.client
            .from('posts')
            .delete()
            .eq('id', widget.postId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully!')),
          );
        }

        if (mounted) {
          setState(() {}); // Refresh the list or handle UI updates
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting post: $e')),
          );
        }
      }
    }
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
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      // Fetch total votes for the post
      final postVotesResponse = await supabase
          .from('posts')
          .select('upvotes, downvotes')
          .eq('id', widget.postId)
          .single();

      // Fetch the user's vote for the post
      final userVoteResponse = await supabase
          .from('votes')
          .select('vote_type')
          .eq('post_id', widget.postId)
          .eq('user_id', userId)
          .maybeSingle();

      setState(() {
        upvotes = postVotesResponse['upvotes'];
        downvotes = postVotesResponse['downvotes'];
        userVote = userVoteResponse?['vote_type']; // Set user's vote type
      });
    } catch (e) {
      debugPrint('Error fetching votes: $e');
    }
  }

  Future<void> _handleVote(String voteType) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) throw 'User not authenticated';

      if (voteType == userVote) {
        // Remove the user's vote
        await supabase
            .from('votes')
            .delete()
            .eq('post_id', widget.postId)
            .eq('user_id', userId);

        final field = voteType == 'upvote' ? 'upvotes' : 'downvotes';
        await supabase.from('posts').update({
          field: field == 'upvotes' ? upvotes - 1 : downvotes - 1
        }).eq('id', widget.postId);

        setState(() {
          if (voteType == 'upvote') {
            upvotes--;
          } else {
            downvotes--;
          }
          userVote = null;
        });
      } else {
        // Switch the user's vote or add a new vote
        if (userVote != null) {
          final previousField = userVote == 'upvote' ? 'upvotes' : 'downvotes';
          await supabase.from('posts').update({
            previousField:
                previousField == 'upvotes' ? upvotes - 1 : downvotes - 1
          }).eq('id', widget.postId);

          await supabase
              .from('votes')
              .update({'vote_type': voteType})
              .eq('post_id', widget.postId)
              .eq('user_id', userId);

          setState(() {
            if (userVote == 'upvote') {
              upvotes--;
            } else {
              downvotes--;
            }
          });
        } else {
          // Insert a new vote
          await supabase.from('votes').insert({
            'user_id': userId,
            'post_id': widget.postId,
            'vote_type': voteType,
          });
        }

        final field = voteType == 'upvote' ? 'upvotes' : 'downvotes';
        await supabase.from('posts').update({
          field: field == 'upvotes' ? upvotes + 1 : downvotes + 1
        }).eq('id', widget.postId);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Title
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                if (_userRole == 'admin')
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditPostScreen(postId: widget.postId),
                          ),
                        );
                      } else if (value == 'delete') {
                        _deletePost(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
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
                        color:
                            userVote == 'upvote' ? Colors.green : Colors.white,
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
                        color:
                            userVote == 'downvote' ? Colors.red : Colors.white,
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
