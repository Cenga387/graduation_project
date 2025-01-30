import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({
    super.key,
  });

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> attendedEvents = [];
  List<Map<String, dynamic>> missedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      // Fetch potential attendance (events the user intended to attend)
      final potentialAttendanceResponse = await supabase
          .from('potential_attendance')
          .select('post_id')
          .eq('user_id', userId);

      List<int> potentialEventIds = potentialAttendanceResponse
          .map<int>((record) => record['post_id'] as int)
          .toList();

      // Fetch actual attendance (events the user actually attended)
      final attendanceResponse = await supabase
          .from('attendance')
          .select('post_id')
          .eq('user_id', userId);

      List<int> attendedEventIds = attendanceResponse
          .map<int>((record) => record['post_id'] as int)
          .toList();

      // Separate attended and missed events
      List<int> missedEventIds = potentialEventIds
          .where((eventId) => !attendedEventIds.contains(eventId))
          .toList();

      // Fetch event details from the "posts" table
      final allEventsResponse = await supabase
          .from('posts')
          .select('id, title, category, created_at')
          .inFilter('id', [...attendedEventIds, ...missedEventIds]);

      List<Map<String, dynamic>> allEvents = List<Map<String, dynamic>>.from(allEventsResponse);

      // Classify attended and missed events
      attendedEvents = allEvents
          .where((event) => attendedEventIds.contains(event['id']))
          .toList();
      missedEvents = allEvents
          .where((event) => missedEventIds.contains(event['id']))
          .toList();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Attended Events",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  attendedEvents.isNotEmpty
                      ? _buildEventList(attendedEvents, Colors.green)
                      : const Text("No attended events."),
                  const SizedBox(height: 20),
                  const Text(
                    "Missed Events",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  missedEvents.isNotEmpty
                      ? _buildEventList(missedEvents, Colors.red)
                      : const Text("No missed events."),
                ],
              ),
            ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events, Color color) {
    return Column(
      children: events.map((event) {
        return Card(
          color: color.withValues(alpha: 0.2),
          child: ListTile(
            title: Text(
              event['title'],
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(event['category']),
            trailing: Text(
              event['created_at'].toString().substring(0, 10),
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        );
      }).toList(),
    );
  }
}