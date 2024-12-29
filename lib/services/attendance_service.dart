import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  Future<void> addToPotentialAttendance(String postId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await supabaseClient.from('potential_attendance').insert({
        'post_id': postId,
        'user_id': userId,
      });

      if (response.error != null) {
        throw 'Error adding to potential attendance: ${response.error!.message}';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsAttended(String postId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await supabaseClient.from('attended').insert({
        'post_id': postId,
        'user_id': userId,
        'scanned_at': DateTime.now().toIso8601String(),
      });

      if (response.error != null) {
        throw 'Error marking attendance: ${response.error!.message}';
      }
    } catch (e) {
      rethrow;
    }
  }
}
