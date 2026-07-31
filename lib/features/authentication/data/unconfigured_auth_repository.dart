import 'package:firstpay/features/authentication/domain/auth_repository.dart';

class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  static const _message =
      'Supabase is not configured. Start FirstPay with the approved local environment file.';

  @override
  Future<void> signIn({required String email, required String password}) {
    throw const AuthFailure(_message);
  }

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String redirectTo,
  }) {
    throw const AuthFailure(_message);
  }

  @override
  Future<void> signOut() {
    throw const AuthFailure(_message);
  }
}
