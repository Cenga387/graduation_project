import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String description;
  final String dateTime;
  final String postId;

  const PostCard({
    Key? key,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
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
            const SizedBox(height: 8),
            // Date and Time
            Text(
              dateTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Upvote and Downvote buttons
                Row(
                  children: [
                    VoteButton(
                      icon: Icons.arrow_upward,
                      isUpvote: true,
                      postId: postId,
                    ),
                    const SizedBox(width: 8),
                    VoteButton(
                      icon: Icons.arrow_downward,
                      isUpvote: false,
                      postId: postId,
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
                            DetailedPostScreen(postId: postId),
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

class VoteButton extends StatefulWidget {
  final IconData icon;
  final bool isUpvote;
  final String postId;

  const VoteButton({
    Key? key,
    required this.icon,
    required this.isUpvote,
    required this.postId,
  }) : super(key: key);

  @override
  State<VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton> {
  bool isSelected = false;

  void _updateVote() async {
    // Replace this logic with Supabase integration
    setState(() {
      isSelected = !isSelected;
    });

    final supabase = Supabase.instance.client;
    final field = widget.isUpvote ? 'upvotes' : 'downvotes';
    await supabase
        .from('posts')
        .update({field: isSelected ? 1 : 0}).eq('id', widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _updateVote,
      child: Icon(
        widget.icon,
        color: isSelected ? Colors.yellow : Colors.white,
        size: 24,
      ),
    );
  }
}

class DetailedPostScreen extends StatelessWidget {
  final String postId;

  const DetailedPostScreen({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement the detailed post screen here
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: Center(child: Text('Details for post $postId')),
    );
  }
}

void main() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MaterialApp(home: SamplePostCard()));
}

class SamplePostCard extends StatelessWidget {
  const SamplePostCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Card Example')),
      body: PostCard(
        title: 'Fortinet Lecture',
        description:
            'Lecture will be held in Red Amphitheatre on Friday, December 8th at 12AM',
        dateTime: 'Friday, December 8th at 12AM',
        postId: 'sample-post-id', // Replace with actual post ID from Supabase
      ),
    );
  }
}
