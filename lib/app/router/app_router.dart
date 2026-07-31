import 'package:firstpay/features/authentication/application/auth_session_provider.dart';
import 'package:firstpay/features/authentication/presentation/login_screen.dart';
import 'package:firstpay/features/customers/presentation/customer_details_screen.dart';
import 'package:firstpay/features/customers/presentation/customer_form_screen.dart';
import 'package:firstpay/features/customers/presentation/customer_list_screen.dart';
import 'package:firstpay/features/dashboard/presentation/dashboard_screen.dart';
import 'package:firstpay/features/enach_mandates/presentation/enach_mandate_details_screen.dart';
import 'package:firstpay/features/enach_mandates/presentation/enach_mandate_form_screen.dart';
import 'package:firstpay/features/enach_mandates/presentation/enach_mandate_list_screen.dart';
import 'package:firstpay/features/organizations/presentation/organization_form_screen.dart';
import 'package:firstpay/features/organizations/presentation/organization_list_screen.dart';
import 'package:firstpay/features/upi_mandates/presentation/upi_mandate_details_screen.dart';
import 'package:firstpay/features/upi_mandates/presentation/upi_mandate_form_screen.dart';
import 'package:firstpay/features/upi_mandates/presentation/upi_mandate_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const organizations = '/patsansthas';
  static const addOrganization = '/patsansthas/new';
  static const customers = '/customers';
  static const addCustomer = '/customers/new';
  static const upiMandates = '/upi-autopay';
  static const createUpiMandate = '/upi-autopay/new';
  static const enachMandates = '/enach';
  static const createEnachMandate = '/enach/new';
  static const resetPassword = '/auth/reset-password';

  static String editOrganizationPath(String id) => '/patsansthas/$id/edit';
  static String customerDetailsPath(String id) => '/customers/$id';
  static String editCustomerPath(String id) => '/customers/$id/edit';
  static String upiMandateDetailsPath(String id) => '/upi-autopay/$id';
  static String editUpiMandatePath(String id) => '/upi-autopay/$id/edit';
  static String enachMandateDetailsPath(String id) => '/enach/$id';
  static String editEnachMandatePath(String id) => '/enach/$id/edit';
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
      GoRoute(
        path: AppRoutes.customers,
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCustomer,
        builder: (context, state) => const CustomerFormScreen(),
      ),
      GoRoute(
        path: '/customers/:id/edit',
        builder: (context, state) =>
            CustomerFormScreen(customerId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) =>
            CustomerDetailsScreen(customerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.upiMandates,
        builder: (context, state) => const UpiMandateListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createUpiMandate,
        builder: (context, state) => const UpiMandateFormScreen(),
      ),
      GoRoute(
        path: '/upi-autopay/:id/edit',
        builder: (context, state) =>
            UpiMandateFormScreen(id: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/upi-autopay/:id',
        builder: (context, state) =>
            UpiMandateDetailsScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.enachMandates,
        builder: (context, state) => const EnachMandateListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createEnachMandate,
        builder: (context, state) => const EnachMandateFormScreen(),
      ),
      GoRoute(
        path: '/enach/:id/edit',
        builder: (context, state) =>
            EnachMandateFormScreen(id: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/enach/:id',
        builder: (context, state) =>
            EnachMandateDetailsScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
