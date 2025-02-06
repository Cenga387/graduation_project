import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  final channel = Supabase.instance.client.channel('public:messages');
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _subscribeToMessages();
  }

  Future<void> _fetchMessages() async {
    final response = await supabase
        .from('messages')
        .select('*')
        .eq('chat_id', widget.chatId)
        .order('created_at', ascending: true);

    setState(() {
      messages = List<Map<String, dynamic>>.from(response);
    });
  }

  void _subscribeToMessages() {
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload, [ref]) {
            if (payload.newRecord['chat_id'] == widget.chatId) {
              setState(() {
                messages.add(Map<String, dynamic>.from(payload.newRecord));
              });
            }
          },
        )
        .subscribe();
  }

  Future<void> _sendMessage() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || _messageController.text.trim().isEmpty) return;

    final messageContent = _messageController.text.trim();
    _messageController.clear();

    await supabase.from('messages').insert({
      'chat_id': widget.chatId,
      'sender_id': userId,
      'content': messageContent,
    });

    await supabase.from('chats').update({
      'last_message': messageContent,
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', widget.chatId);
  }

  @override
  void dispose() {
    super.dispose();
    channel.unsubscribe();
    supabase.removeAllChannels();
    _messageController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe =
                    message['sender_id'] == supabase.auth.currentUser?.id;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(message['content']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
