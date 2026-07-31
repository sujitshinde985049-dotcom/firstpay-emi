import 'package:firstpay/features/authentication/application/auth_session_provider.dart';
import 'package:firstpay/features/authentication/presentation/login_screen.dart';
import 'package:firstpay/features/dashboard/presentation/dashboard_screen.dart';
import 'package:firstpay/features/organizations/presentation/organization_form_screen.dart';
import 'package:firstpay/features/organizations/presentation/organization_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const organizations = '/patsansthas';
  static const addOrganization = '/patsansthas/new';
  static const resetPassword = '/auth/reset-password';

  static String editOrganizationPath(String id) => '/patsansthas/$id/edit';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionProvider);
  final authSession = session.asData?.value;
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      if (authSession == null) return null;
      final atLogin = state.matchedLocation == AppRoutes.login;
      if (authSession.isAuthenticated && atLogin) {
        return AppRoutes.dashboard;
      }
      if (!authSession.isAuthenticated && !atLogin) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.organizations,
        builder: (context, state) => const OrganizationListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addOrganization,
        builder: (context, state) => const OrganizationFormScreen(),
      ),
      GoRoute(
        path: '/patsansthas/:id/edit',
        builder: (context, state) =>
            OrganizationFormScreen(organizationId: state.pathParameters['id']),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
