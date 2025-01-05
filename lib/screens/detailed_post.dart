import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/attendance_service.dart'; // Import your AttendanceService
import 'qr_scanner.dart'; // Import your QR Code Scanner Screen

class DetailedPostScreen extends StatefulWidget {
  final String postId;

  const DetailedPostScreen({super.key, required this.postId});

  @override
  State<DetailedPostScreen> createState() => _DetailedPostScreenState();
}

class _DetailedPostScreenState extends State<DetailedPostScreen> {
  final AttendanceService _attendanceService = AttendanceService();

  bool isUserInAttendance =
      false; // Tracks if the user has confirmed attendance
  bool isUserAttending = false; // Tracks if the user clicked to attend
  bool isLoading = false; // Tracks loading state
  String? qrCodeImageUrl;
  String? qrCodeRawData;

  @override
  void initState() {
    super.initState();
    _fetchQRCodeImageUrl();
    _checkAttendance();
    _checkPotentialAttendanceStatus();
  }

  Future<void> _fetchQRCodeImageUrl() async {
    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select('qr_code_image_url, qr_code_raw_data')
          .eq('id', widget.postId)
          .maybeSingle();

      if (response == null) throw 'Post not found';

      setState(() {
        qrCodeImageUrl = response['qr_code_image_url'] as String?;
        qrCodeRawData = response['qr_code_raw_data'] as String?;
      });
    } catch (e) {
      debugPrint('Error fetching QR code details: $e');
    }
  }

  Future<void> _checkAttendance() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await Supabase.instance.client
          .from('attendance')
          .select()
          .eq('post_id', widget.postId)
          .eq('user_id', userId)
          .limit(1)
          .maybeSingle(); // Fetch single entry or null

      setState(() {
        isUserInAttendance = response != null;
        isLoading = false;
      });
      debugPrint(
          'Attendance check: ${response != null ? "User is in attendance" : "User is not in attendance"}');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error checking attendance status: $e');
    }
  }

  Future<void> _checkPotentialAttendanceStatus() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      final response = await Supabase.instance.client
          .from('potential_attendance')
          .select()
          .eq('post_id', widget.postId)
          .eq('user_id', userId)
          .maybeSingle(); // Fetch single entry or null

      setState(() {
        isUserAttending = response != null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error checking attendance status: $e');
    }
  }

  // Shows confirmation modal
  void _showAttendConfirmationModal(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Attendance'),
          content: const Text(
              'Do you want to mark yourself as attending this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close modal
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close modal
                await _confirmAttendance(postId);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Confirms attendance
  Future<void> _confirmAttendance(String postId) async {
    setState(() {
      isLoading = true;
    });

    try {
      await _attendanceService.addToPotentialAttendance(postId);
      setState(() {
        isUserAttending = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are marked as attending!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('posts')
            .select()
            .eq('id', widget.postId)
            .single(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading post details.'));
          }

          final data = snapshot.data as Map<String, dynamic>;
          final String category =
              data['category']; // Extract category from the post

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['content'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Upvotes: ${data['upvotes']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Downvotes: ${data['downvotes']}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Conditionally render buttons based on category and attendance
                if (category == 'Event') ...[
                  if (isUserInAttendance)
                    const Text(
                      'You are attending this event.',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    )
                  else if (isUserAttending)
                    IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodeScannerScreen(
                              postId: widget.postId,
                              qrCodeImageUrl: qrCodeImageUrl,
                              qrCodeRawData: qrCodeRawData,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _showAttendConfirmationModal(widget.postId),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Attend'),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
