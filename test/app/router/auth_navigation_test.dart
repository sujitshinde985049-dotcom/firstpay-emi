import 'dart:async';

import 'package:firstpay/app/app.dart';
import 'package:firstpay/app/localization/app_strings.dart';
import 'package:firstpay/features/authentication/application/auth_controller.dart';
import 'package:firstpay/features/authentication/application/auth_session_provider.dart';
import 'package:firstpay/features/authentication/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _LogoutRepository implements AuthRepository {
  _LogoutRepository(this.sessions);

  final StreamController<AuthSessionState> sessions;
  bool signedOut = false;

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String redirectTo,
  }) async {}

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {
    signedOut = true;
    sessions.add(const AuthSessionState.unauthenticated());
  }
}

void main() {
  testWidgets('unauthenticated session routes to login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            (ref) => Stream.value(const AuthSessionState.unauthenticated()),
          ),
        ],
        child: const FirstPayApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text('Welcome to FirstPay'), findsNothing);
  });

  testWidgets('authenticated session shows enterprise dashboard data', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            (ref) => Stream.value(
              const AuthSessionState.authenticated('admin@firstpay.in'),
            ),
          ),
        ],
        child: const FirstPayApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to FirstPay'), findsOneWidget);
    expect(find.text('admin@firstpay.in'), findsOneWidget);
    expect(find.text('Super Admin'), findsOneWidget);
    expect(find.text('Current Role'), findsOneWidget);
    expect(find.text('Last Login'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);
    for (final label in [
      'Total Patsansthas',
      'Total Customers',
      'Active UPI Mandates',
      'Active e-NACH Mandates',
      "Today's Mandates",
      'Pending Mandates',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text(AppStrings.loginTitle), findsNothing);
  });

  testWidgets('dashboard drawer exposes approved placeholder destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            (ref) => Stream.value(
              const AuthSessionState.authenticated('admin@firstpay.in'),
            ),
          ),
        ],
        child: const FirstPayApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsNWidgets(2));
    for (final label in [
      'Patsansthas',
      'Customers',
      'UPI AutoPay',
      'e-NACH',
      'Reports',
      'Settings',
      'Logout',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('logout returns an authenticated user to login', (tester) async {
    final sessions = StreamController<AuthSessionState>();
    final repository = _LogoutRepository(sessions);
    addTearDown(sessions.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith((ref) => sessions.stream),
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const FirstPayApp(),
      ),
    );
    sessions.add(const AuthSessionState.authenticated('admin@firstpay.in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to FirstPay'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(repository.signedOut, isTrue);
    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text('Welcome to FirstPay'), findsNothing);
  });
}
