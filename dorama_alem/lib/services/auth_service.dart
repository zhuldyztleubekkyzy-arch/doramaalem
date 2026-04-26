import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  firebase_auth.User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> signUp({
  required String email,
  required String password,
  required String name,
}) async {
  try {
    firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    firebase_auth.User? user = result.user;

    if (user == null || user.uid.isEmpty) {
      await _auth.currentUser?.reload();
      user = _auth.currentUser;
    }

    if (user == null || user.uid.isEmpty) {
      return {'success': false, 'message': 'Firebase пайдаланушы анықталмады'};
    }

    final response = await _supabase.from('users').insert({
      'firebase_uid': user.uid,
      'email': email,
      'name': name,
      'role': 'viewer',
    }).select();

    print('✅ Supabase insert response: $response');

    return {'success': true, 'message': 'Тіркелу сәтті өтті'};
  } on firebase_auth.FirebaseAuthException catch (e) {
    return {'success': false, 'message': _getErrorMessage(e.code)};
  } catch (e, st) {
    print('🔥 Signup general error: $e');
    print(st);
    return {'success': false, 'message': 'Қате: ${e.toString()}'};
  }
}


  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'message': 'Кіру сәтті өтті'};
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Қате: ${e.toString()}'};
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> getUserRole() async {
    try {
      final user = currentUser;
      if (user == null) return 'viewer';

      final response = await _supabase
          .from('users')
          .select('role')
          .eq('firebase_uid', user.uid)
          .single();

      return response['role'] ?? 'viewer';
    } catch (e) {
      return 'viewer';
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', user.uid)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Құпия сөз тым әлсіз';
      case 'email-already-in-use':
        return 'Бұл email тіркелген';
      case 'invalid-email':
        return 'Email форматы қате';
      case 'user-not-found':
        return 'Пайдаланушы табылмады';
      case 'wrong-password':
        return 'Құпия сөз қате';
      default:
        return 'Қате орын алды';
    }
  }
}