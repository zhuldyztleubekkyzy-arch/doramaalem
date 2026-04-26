import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user stream
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return AppUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    });
  }

  // Get current user
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) return null;
      return AppUser(
        uid: credential.user!.uid,
        email: credential.user!.email,
        displayName: credential.user!.displayName,
        photoUrl: credential.user!.photoURL,
      );
    } catch (e) {
      throw Exception('Кіру қатесі: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<AppUser?> registerWithEmailAndPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) return null;

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
      }

      return AppUser(
        uid: credential.user!.uid,
        email: credential.user!.email,
        displayName: credential.user!.displayName ?? displayName,
        photoUrl: credential.user!.photoURL,
      );
    } catch (e) {
      throw Exception('Тіркелу қатесі: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Шығу қатесі: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Құпия сөзді қалпына келтіру қатесі: ${e.toString()}');
    }
  }
}

