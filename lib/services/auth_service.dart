import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  //sign with email and pass

  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  //signUp with email n' pass

  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  //sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  //get user mail

  String? getCurrentUserEmail() {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
