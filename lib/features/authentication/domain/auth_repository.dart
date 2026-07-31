abstract interface class AuthRepository {
  Future<void> signIn({required String email, required String password});

  Future<void> sendPasswordReset({
    required String email,
    required String redirectTo,
  });

  Future<void> signOut();
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}
