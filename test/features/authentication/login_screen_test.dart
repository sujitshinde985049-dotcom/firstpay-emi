import 'package:firstpay/app/localization/app_strings.dart';
import 'package:firstpay/app/theme/firstpay_theme.dart';
import 'package:firstpay/features/authentication/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject() =>
      MaterialApp(theme: FirstPayTheme.light, home: const LoginScreen());

  testWidgets('shows required errors only after sign in', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text(AppStrings.emailRequiredMessage), findsNothing);
    expect(find.text(AppStrings.passwordRequiredMessage), findsNothing);

    await tester.tap(find.text(AppStrings.signIn));
    await tester.pump();

    expect(find.text(AppStrings.emailRequiredMessage), findsOneWidget);
    expect(find.text(AppStrings.passwordRequiredMessage), findsOneWidget);
  });

  testWidgets('accepts required values without backend work', (tester) async {
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
    await tester.pump();

    expect(find.text(AppStrings.emailRequiredMessage), findsNothing);
    expect(find.text(AppStrings.passwordRequiredMessage), findsNothing);
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
