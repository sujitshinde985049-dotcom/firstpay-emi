import 'package:firstpay/features/foundation/presentation/design_system_preview_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const preview = '/';
  static const resetPassword = '/auth/reset-password';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.preview,
    routes: [
      GoRoute(
        path: AppRoutes.preview,
        builder: (context, state) => const DesignSystemPreviewScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
