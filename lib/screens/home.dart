import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>{
   Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    // Navigate to the login screen or home screen after logout
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SizedBox(
      child: ElevatedButton(onPressed: () => _signOut(context), child: Text('Sign Out')),
      ),
    );
  }
}