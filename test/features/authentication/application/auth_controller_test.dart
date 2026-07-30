import 'package:firstpay/features/authentication/application/auth_controller.dart';
import 'package:firstpay/features/authentication/domain/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingRepository implements AuthRepository {
  bool fail = false;
  String? signInEmail;
  String? resetRedirect;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (fail) throw const AuthFailure('Safe authentication error');
    signInEmail = email;
  }

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String redirectTo,
  }) async {
    if (fail) throw const AuthFailure('Safe reset error');
    resetRedirect = redirectTo;
  }
}

void main() {
  test(
    'sign in delegates credentials without retaining them in state',
    () async {
      final repository = _RecordingRepository();
      final controller = AuthController(repository);

      final succeeded = await controller.signIn(
        email: 'demo@firstpay.in',
        password: 'not-a-real-password',
      );

      expect(succeeded, isTrue);
      expect(repository.signInEmail, 'demo@firstpay.in');
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
      expect(
        controller.state.toString(),
        isNot(contains('not-a-real-password')),
      );
    },
  );

  test('password reset uses the approved redirect URL', () async {
    final repository = _RecordingRepository();
    final controller = AuthController(repository);

    final succeeded = await controller.sendPasswordReset('demo@firstpay.in');

    expect(succeeded, isTrue);
    expect(repository.resetRedirect, passwordResetRedirectUrl);
  });

  test('safe repository failures are exposed without throwing', () async {
    final repository = _RecordingRepository()..fail = true;
    final controller = AuthController(repository);

    final succeeded = await controller.signIn(
      email: 'demo@firstpay.in',
      password: 'not-a-real-password',
    );

    expect(succeeded, isFalse);
    expect(controller.state.errorMessage, 'Safe authentication error');
  });
}
