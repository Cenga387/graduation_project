import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  Future<void> addToPotentialAttendance(String postId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      await supabaseClient.from('potential_attendance').insert({
        'post_id': postId,
        'user_id': userId,
        'user_email': supabaseClient.auth.currentUser!.email,
      });
    } catch (e) {
      throw 'Error adding to potential attendance: $e';
    }
  }

  Future<bool> verifyQRCode(String postId, String scannedQRCode) async {
    try {
      // Fetch the QR code data from the posts table
      final response = await supabaseClient
          .from('posts')
          .select('qr_code_image_url')
          .eq('id', postId)
          .maybeSingle();

      if (response == null) throw 'Post not found';

      final qrCodeData = response['qr_code_image_url'];
      if (qrCodeData == null) throw 'QR code data not found';

      // Compare the scanned QR code with the stored QR code data
      return qrCodeData == scannedQRCode;
    } catch (e) {
      throw 'Error verifying QR code: $e';
    }
  }

  Future<bool> isAlreadyMarked(String postId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await supabaseClient
          .from('attendance')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null; // If a record exists, the user is already marked
    } catch (e) {
      throw 'Error checking attendance: $e';
    }
  }

  // Mark the user as attended in the attendance table
  Future markAsAttended(String postId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      await supabaseClient.from('attendance').insert({
        'post_id': postId,
        'user_id': userId,
        'user_email': supabaseClient.auth.currentUser!.email,
        'attended_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Error marking attendance: $e';
    }
  }
}
