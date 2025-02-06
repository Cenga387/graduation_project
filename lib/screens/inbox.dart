import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat.dart';
import 'new_chat.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final supabase = Supabase.instance.client;
  final channel = Supabase.instance.client.channel('public:chats');
  List<Map<String, dynamic>> chats = [];
  final Map<String, String> _chatTitles = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
    _subscribeToChatUpdates();
  }

  @override
  void dispose() {
    // Clean up any resources here
    super.dispose();
    channel.unsubscribe();
    supabase.removeAllChannels();
  }

  Future<void> _fetchChats() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('chats')
        .select('id, name, last_message, is_group, chat_participants!inner(user_id)')
        .eq('chat_participants.user_id', userId)
        .order('last_message_time', ascending: false);

    final chatList = List<Map<String, dynamic>>.from(response);

    // Fetch titles for each chat
    for (var chat in chatList) {
      final chatId = chat['id'];
      final title = await _getChatTitle(chat);
      _chatTitles[chatId] = title;
    }

    if (mounted) {
      setState(() {
        chats = chatList;
        isLoading = false;
      });
    }
  }

  Future<String> _getChatTitle(Map<String, dynamic> chat) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 'Chat';

    if (chat['is_group'] == true) {
      return chat['name'] ?? 'Group Chat';
    }

    final participants = await supabase
        .from('chat_participants')
        .select('user_id')
        .eq('chat_id', chat['id'])
        .neq('user_id', userId);

    if (participants.isNotEmpty) {
      final otherUserId = participants[0]['user_id'];
      final userData = await supabase
          .from('profile')
          .select('username')
          .eq('user_id', otherUserId)
          .single();
      return userData['username'] ?? 'Chat';
    }

    return 'Chat';
  }

  void _subscribeToChatUpdates() {
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chats',
          callback: (payload, [ref]) {
            _fetchChats();
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body:  isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final chatId = chat['id'];
                final chatTitle = _chatTitles[chatId] ?? 'Loading...';

                return ListTile(
                  title: Text(chatTitle),
                  subtitle: Text(chat['last_message'] ?? 'No messages yet'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: chatId),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewChatScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
