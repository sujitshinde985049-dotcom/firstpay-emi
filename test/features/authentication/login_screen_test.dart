import 'package:firstpay/app/localization/app_strings.dart';
import 'package:firstpay/app/theme/firstpay_theme.dart';
import 'package:firstpay/features/authentication/application/auth_controller.dart';
import 'package:firstpay/features/authentication/domain/auth_repository.dart';
import 'package:firstpay/features/authentication/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  String? signedInEmail;
  String? resetEmail;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signedInEmail = email;
  }

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String redirectTo,
  }) async {
    resetEmail = email;
  }
}

void main() {
  late _FakeAuthRepository repository;

  setUp(() => repository = _FakeAuthRepository());

  Widget buildSubject() => ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: FirstPayTheme.light, home: const LoginScreen()),
  );

  testWidgets('shows required errors only after sign in', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text(AppStrings.emailRequiredMessage), findsNothing);
    expect(find.text(AppStrings.passwordRequiredMessage), findsNothing);

    await tester.tap(find.text(AppStrings.signIn));
    await tester.pump();

    expect(find.text(AppStrings.emailRequiredMessage), findsOneWidget);
    expect(find.text(AppStrings.passwordRequiredMessage), findsOneWidget);
  });

  testWidgets('submits required values to the auth boundary', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.emailLabel),
      'demo@firstpay.in',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.passwordLabel),
      'demo-password',
    );
    await tester.tap(find.text(AppStrings.signIn));
    await tester.pumpAndSettle();

    expect(repository.signedInEmail, 'demo@firstpay.in');
    expect(find.text(AppStrings.emailRequiredMessage), findsNothing);
    expect(find.text(AppStrings.passwordRequiredMessage), findsNothing);
  });

  testWidgets('initiates password reset for the entered email', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.emailLabel),
      'demo@firstpay.in',
    );

    await tester.tap(find.text(AppStrings.forgotPassword));
    await tester.pumpAndSettle();

    expect(repository.resetEmail, 'demo@firstpay.in');
  });

  testWidgets('fits a narrow mobile viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.signIn), findsOneWidget);
  });
}
