import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart'; // Update this import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isSigningOut = false;

  Future<void> _signOut(BuildContext context) async {
    _isSigningOut = true;
    try {
      await _authService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isSigningOut = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authService.ensureInitialized(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            print('Profile auth state: ${snapshot.data?.email}');

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = snapshot.data ?? _authService.currentUser;
            if (user == null) {
              print('No user found, redirecting to sign in');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen(), // Update this reference
                  ),
                  (route) => false,
                );
              });
              return const Center(child: CircularProgressIndicator());
            }

            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 24),
                      ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(user.email ?? 'No email'),
                        subtitle: Text(
                          'Member since ${user.metadata.creationTime?.toString() ?? 'N/A'}',
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text('Sign Out'),
                        trailing: _isSigningOut
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                        onTap: _isSigningOut ? null : () => _signOut(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
