import 'package:firstpay/app/app.dart';
import 'package:firstpay/app/localization/app_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the FirstPay login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FirstPayApp()));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.text(AppStrings.forgotPassword), findsOneWidget);
    expect(find.text(AppStrings.rememberMe), findsOneWidget);
    expect(find.text(AppStrings.signIn), findsOneWidget);
    expect(find.text(AppStrings.versionLabel), findsOneWidget);
  });
}
