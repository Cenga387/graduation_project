import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDataProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  Map<String, dynamic> posts = {};
  Map<String, String?> userVotes = {};
  Map<String, List<String>> categorizedPosts = {};
  String? userRole;
  bool isLoading = true;

  Future<void> initializeApp() async {
    try {
      await Future.wait([
        _fetchUserRole(),
        _fetchAllPosts(),
      ]);
    } catch (e) {
      debugPrint("Error initializing app: $e");
    } finally {
      isLoading = false;
      notifyListeners(); // Notify the app that data is ready
    }
  }


  Future<void> refreshPosts() async {
    isLoading = true;
    notifyListeners();
    await _fetchAllPosts();
  }
Future<void> _fetchUserRole() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('profile')
          .select('role')
          .eq('user_id', userId)
          .single();

      userRole = response['role'];
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  Future<void> _fetchAllPosts() async {
    try {
      final response = await supabase.from('posts').select('id, title, description, category, upvotes, downvotes');
      final data = response as List<dynamic>;

      final Map<String, List<String>> postsByCategory = {};
      Map<String, dynamic> postsMap = {};

      for (var post in data) {
        final String category = post['category'];
        final int postId = post['id'];

        // Store posts in a map for quick lookup
        postsMap[postId.toString()] = post;

        // Group 'Announcement' posts under a common key
        final categoryKey =
            category.contains('Announcement') ? 'Announcement' : category;

        if (!postsByCategory.containsKey(categoryKey)) {
          postsByCategory[categoryKey] = [];
        }
        postsByCategory[categoryKey]!.add(postId.toString());
      }

      posts = postsMap;
      categorizedPosts = postsByCategory;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> handleVote(String postId, String voteType) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      if (voteType == userVotes[postId]) {
        await supabase
            .from('votes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        posts[postId]![voteType == 'upvote' ? 'upvotes' : 'downvotes'] -= 1;
        userVotes[postId] = null;
      } else {
        if (userVotes[postId] != null) {
          final previousField = userVotes[postId] == 'upvote' ? 'upvotes' : 'downvotes';
          posts[postId]![previousField] -= 1;
        }

        await supabase.from('votes').upsert({
          'user_id': userId,
          'post_id': postId,
          'vote_type': voteType,
        });

        posts[postId]![voteType == 'upvote' ? 'upvotes' : 'downvotes'] += 1;
        userVotes[postId] = voteType;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error handling votes: $e');
    }
  }

  Future<void> deletePost(String postId, BuildContext context) async {
    try {
      await supabase.from('posts').delete().eq('id', postId);
      posts.remove(postId);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully!')),
      );
    } catch (e) {
      debugPrint('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  Map<String, dynamic>? getPost(String postId) => posts[postId];
  String? getUserVote(String postId) => userVotes[postId];
  
  }
