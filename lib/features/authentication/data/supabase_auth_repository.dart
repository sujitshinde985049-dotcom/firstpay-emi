import 'package:firstpay/features/authentication/domain/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error));
    } on Object {
      throw const AuthFailure(
        'Unable to sign in right now. Please check your connection and try again.',
      );
    }
  }

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String redirectTo,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: redirectTo,
      );
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error));
    } on Object {
      throw const AuthFailure(
        'Unable to send the reset email right now. Please try again.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      throw const AuthFailure(
        'Unable to sign out right now. Please try again.',
      );
    } on Object {
      throw const AuthFailure(
        'Unable to sign out right now. Please try again.',
      );
    }
  }

  String _friendlyMessage(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'The email or password is incorrect.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return 'Authentication could not be completed. Please try again.';
  }
}
