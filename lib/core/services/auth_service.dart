import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuthentication,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _localAuthentication = localAuthentication ?? LocalAuthentication();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuthentication;

  static const _emailKey = 'biometric_login_email';
  static const _passwordKey = 'biometric_login_password';

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _saveBiometricCredentials(email.trim(), password);
      return response;
    } catch (error) {
      debugPrint('Sign-in failed: $error');
      rethrow;
    }
  }

  Future<AuthResponse> loginWithBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final availableBiometrics = await _localAuthentication
          .getAvailableBiometrics();
      if (!canCheckBiometrics || availableBiometrics.isEmpty) {
        throw const BiometricAuthException(
          'Biometrik belum tersedia atau belum didaftarkan di perangkat.',
        );
      }

      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Gunakan sidik jari atau Face ID untuk login',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (!authenticated) {
        throw const BiometricAuthException('Autentikasi biometrik dibatalkan.');
      }

      final email = await _secureStorage.read(key: _emailKey);
      final password = await _secureStorage.read(key: _passwordKey);
      if (email == null ||
          email.trim().isEmpty ||
          password == null ||
          password.isEmpty) {
        throw const BiometricAuthException(
          'Silakan login dengan email dan password terlebih dahulu.',
        );
      }

      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on LocalAuthException catch (error) {
      debugPrint('Biometric sign-in failed: $error');
      if (error.code == LocalAuthExceptionCode.userCanceled ||
          error.code == LocalAuthExceptionCode.systemCanceled) {
        throw const BiometricAuthException('Autentikasi biometrik dibatalkan.');
      }
      if (error.code == LocalAuthExceptionCode.noBiometricHardware ||
          error.code == LocalAuthExceptionCode.noBiometricsEnrolled ||
          error.code == LocalAuthExceptionCode.noCredentialsSet) {
        throw const BiometricAuthException(
          'Biometrik belum tersedia atau belum didaftarkan di perangkat.',
        );
      }
      throw const BiometricAuthException(
        'Autentikasi biometrik tidak dapat digunakan.',
      );
    } catch (error) {
      debugPrint('Biometric sign-in failed: $error');
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

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (error) {
      debugPrint('Password reset email failed: $error');
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

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> _saveBiometricCredentials(String email, String password) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
  }
}

class BiometricAuthException implements Exception {
  const BiometricAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
