import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _authDebouncer;
  bool _isAuthInProgress = false;
  bool _initialized = false;
  final _initCompleter = Completer<void>();

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    if (_initialized) return;
    try {
      // Wait for Firebase Auth to initialize
      await Future.delayed(const Duration(seconds: 1));

      print('Current user on init: ${_auth.currentUser?.email}');
      _initialized = true;
      _initCompleter.complete();
    } catch (e) {
      print('Auth initialization error: $e');
      _initCompleter.completeError(e);
    }
  }

  // Ensure auth is initialized before any operation
  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await _initCompleter.future;
    }
  }

  // Enhanced auth state stream
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      print('Auth state changed: ${user?.email}');
      return user;
    });
  }

  // Enhanced current user getter
  User? get currentUser {
    final user = _auth.currentUser;
    print('Current user check: ${user?.email}');
    return user;
  }

  // Sign in with better state management
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    if (_isAuthInProgress) {
      throw 'Authentication already in progress';
    }

    _isAuthInProgress = true;
    try {
      // First sign out to clear any existing state
      if (_auth.currentUser != null) {
        print('Signing out existing user before new sign in');
        await _auth.signOut();
        // Small delay to ensure state is cleared
        await Future.delayed(Duration(milliseconds: 300));
      }

      print('Attempting to sign in user: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Sign in successful for user: ${credential.user?.email}');
      return credential;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    } finally {
      // Reset auth state after a delay
      _authDebouncer?.cancel();
      _authDebouncer = Timer(Duration(seconds: 2), () {
        _isAuthInProgress = false;
      });
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
      throw e.message ?? 'An error occurred during sign up';
    }
  }

  // Sign out with persistence clearing
  Future<void> signOut() async {
    try {
      _authDebouncer?.cancel();
      _isAuthInProgress = false;

      // Sign out from all instances
      await Future.wait([
        _auth.signOut(),
        FirebaseAuth.instance.signOut(),
      ]);

      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
      throw 'Failed to sign out: $e';
    }
  }

  void dispose() {
    _authDebouncer?.cancel();
  }
}
