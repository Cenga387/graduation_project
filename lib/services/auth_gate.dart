import 'package:flutter/material.dart';
import 'package:graduation_project/screens/main_navigation.dart';
import '../screens/welcome.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold();
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const MainNavigation();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
