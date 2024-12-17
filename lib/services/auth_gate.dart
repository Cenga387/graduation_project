import 'package:flutter/material.dart';
import '../screens/welcome.dart';
import '../screens/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //listen to the auth state change
      stream: Supabase.instance.client.auth.onAuthStateChange,
      //building the appropriate screen for the current auth state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold();
        }

        //to check if we have already current session

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          //if session is not null then go to home page
          return const HomePage();
        } else {
          // SignInScreen();
          return const WelcomeScreen();
        }
      },
    );
  }
}