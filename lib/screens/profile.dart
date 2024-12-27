import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}


class _ProfilePageState extends State<ProfilePage>{
  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (context.mounted) {
      // Navigate to the login screen or home screen after logout
      Navigator.pushReplacementNamed(context, '/login');
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: ElevatedButton(
            onPressed: () => _signOut(context), child: const Text('Sign Out')),
      ),
    );
  }
}
