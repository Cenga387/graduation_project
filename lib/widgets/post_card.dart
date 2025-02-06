import 'package:flutter/material.dart';
import 'package:graduation_project/screens/detailed_post.dart';
import 'package:graduation_project/screens/edit_post.dart';
import 'package:graduation_project/providers/app_data_provider.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget {
  final String postId;

  const PostCard({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataProvider>(
      builder: (context, appData, child) {
        final post = appData.getPost(postId);
        final userVote = appData.getUserVote(postId);
        final userRole = appData.userRole;

        if (post == null) {
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
                  children: [
                    Expanded(
                      child: Text(
                        post['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    if (userRole == 'admin')
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPostScreen(postId: postId),
                              ),
                            );
                          } else if (value == 'delete') {
                            appData.deletePost(postId, context);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post['description'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_upward,
                            color: userVote == 'upvote' ? Colors.green : Colors.white,
                          ),
                          onPressed: () => appData.handleVote(postId, 'upvote'),
                        ),
                        Text(
                          '${post['upvotes'] - post['downvotes']}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_downward,
                            color: userVote == 'downvote' ? Colors.red : Colors.white,
                          ),
                          onPressed: () => appData.handleVote(postId, 'downvote'),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailedPostScreen(postId: postId),
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
      },
    );
  }
}
