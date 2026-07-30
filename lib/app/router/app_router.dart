import 'package:firstpay/features/authentication/presentation/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const login = '/';
  static const resetPassword = '/auth/reset-password';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
