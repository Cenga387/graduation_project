import 'package:graduation_project/screens/announcements.dart';
import 'package:graduation_project/screens/welcome.dart';
import 'services/auth_gate.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/create_post.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://wgxhhiqhjoyonzezyuyo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndneGhoaXFoam95b256ZXp5dXlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE0MjYwNTEsImV4cCI6MjA0NzAwMjA1MX0.S08QtzHm7J-H-9ZlcFJxhv1i6iX4OKszFkEa8j5com0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'IUS Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005597)),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005597), // Blue background
              foregroundColor: Colors.white, // White text
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF005597), // Blue background
              foregroundColor: Colors.white, // White text
            ),
          ),
        ),
        home: const AuthGate(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/create_post': (context) => const CreatePostScreen(),
          '/announcements': (context) => const AnnouncementPage(),
        });
  }
}
