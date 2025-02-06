import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    // Clean up any resources here
    super.dispose();
    searchController.dispose();
  }

  Future<void> _fetchUsers() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('profile')
        .select('user_id, username')
        .neq('user_id', userId);

    setState(() {
      users = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _createChat(List<String> selectedUserIds, String? groupName) async {
  final supabase = Supabase.instance.client;
  final currentUserId = supabase.auth.currentUser?.id;

  if (currentUserId == null) return;

  // Determine if it's a group chat
  bool isGroup = selectedUserIds.length > 1;

  final chatResponse = await supabase.from('chats').insert({
    'is_group': isGroup,
    'name': isGroup ? groupName : null, // Only assign name if it's a group
  }).select('id').single();

  final chatId = chatResponse['id'];

  // Add the current user to the chat
  await supabase.from('chat_participants').insert({
    'chat_id': chatId,
    'user_id': currentUserId,
  });

  // Add other participants
  for (final userId in selectedUserIds) {
    await supabase.from('chat_participants').insert({
      'chat_id': chatId,
      'user_id': userId,
    });
  }

  if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId)),
      );
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  users = users
                      .where((user) => user['username']
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['username']),
                  onTap: () => _createChat(user['user_id'], user['username']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
