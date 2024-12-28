import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<String?> _fetchUsername() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return null;

    final response = await Supabase.instance.client
        .from('profile')
        .select('username')
        .eq('user_id', userId)
        .single();

    if (response == null) {
      debugPrint('No data returned from the database.');
      return null;
    }

    if (response is Map<String, dynamic>) {
      return response['username'] as String?;
    } else {
      debugPrint('Unexpected response type: ${response.runtimeType}');
      return null;
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/oliver.jpg'),
                ),
                const SizedBox(height: 10),
                FutureBuilder<String?>(
                  future: _fetchUsername(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Error loading username',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return const Text(
                        'Guest user',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, size: 18, color: Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      Supabase.instance.client.auth.currentUser?.email ??
                          'No email',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 5),
                    Text(
                      'Ciglane, Sarajevo',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Divider(thickness: 0.5, color: Colors.grey),
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(
                  icon: Icons.person,
                  text: 'Profile',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.notifications,
                  text: 'Notifications',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.edit,
                  text: 'Edit Profile',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  text: 'Log out',
                  onTap: () {
                    _signOut(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 24),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}
