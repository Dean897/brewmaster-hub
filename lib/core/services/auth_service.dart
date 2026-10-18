import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      debugPrint('Sign-in failed: $error');
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      return await _supabase.auth.signUp(email: email, password: password);
    } catch (error) {
      debugPrint('Sign-up failed: $error');
      rethrow;
    }
  }

  Future<void> createProfile({required String fullName}) async {
    try {
      await _supabase.from('profiles').insert({'full_name': fullName});
    } catch (error) {
      debugPrint('Profile creation failed: $error');
      rethrow;
    }
  }
}
