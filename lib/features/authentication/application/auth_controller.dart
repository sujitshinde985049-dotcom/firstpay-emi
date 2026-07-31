import 'package:firstpay/features/authentication/data/supabase_auth_repository.dart';
import 'package:firstpay/features/authentication/data/unconfigured_auth_repository.dart';
import 'package:firstpay/features/authentication/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const passwordResetRedirectUrl = 'https://app.firstpay.in/auth/reset-password';

class AuthUiState {
  const AuthUiState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  try {
    return SupabaseAuthRepository(Supabase.instance.client);
  } on Object {
    return const UnconfiguredAuthRepository();
  }
});

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AuthUiState>(
      (ref) => AuthController(ref.watch(authRepositoryProvider)),
    );

class AuthController extends StateNotifier<AuthUiState> {
  AuthController(this._repository) : super(const AuthUiState());

  final AuthRepository _repository;

  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthUiState(isLoading: true);
    try {
      await _repository.signIn(email: email, password: password);
      state = const AuthUiState(successMessage: 'Signed in successfully.');
      return true;
    } on AuthFailure catch (error) {
      state = AuthUiState(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AuthUiState(isLoading: true);
    try {
      await _repository.sendPasswordReset(
        email: email,
        redirectTo: passwordResetRedirectUrl,
      );
      state = const AuthUiState(
        successMessage:
            'If an account exists, a password reset email was sent.',
      );
      return true;
    } on AuthFailure catch (error) {
      state = AuthUiState(errorMessage: error.message);
      return false;
    }
  }

  Future<bool> signOut() async {
    state = const AuthUiState(isLoading: true);
    try {
      await _repository.signOut();
      state = const AuthUiState();
      return true;
    } on AuthFailure catch (error) {
      state = AuthUiState(errorMessage: error.message);
      return false;
    }
  }
}
