import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/core/widgets/firstpay_logo.dart';
import 'package:firstpay/features/authentication/application/auth_controller.dart';
import 'package:firstpay/features/authentication/application/auth_session_provider.dart';
import 'package:firstpay/features/dashboard/application/dashboard_view_data_provider.dart';
import 'package:firstpay/features/dashboard/presentation/dashboard_destination.dart';
import 'package:firstpay/features/dashboard/widgets/dashboard_summary_card.dart';
import 'package:firstpay/features/dashboard/widgets/dashboard_user_card.dart';
import 'package:firstpay/features/dashboard/widgets/firstpay_dashboard_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardDestination _selectedDestination = DashboardDestination.dashboard;

  static const _metricIcons = [
    Icons.account_balance_outlined,
    Icons.people_outline,
    Icons.autorenew_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.today_outlined,
    Icons.pending_actions_outlined,
  ];

  void _selectDestination(DashboardDestination destination) {
    Navigator.of(context).pop();
    setState(() => _selectedDestination = destination);
    switch (destination) {
      case DashboardDestination.dashboard:
        context.go(AppRoutes.dashboard);
      case DashboardDestination.patsansthas:
        context.go(AppRoutes.organizations);
      case DashboardDestination.settings:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings are coming soon.')),
        );
    }
  }

  void _signOut() {
    ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthUiState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });
    final session = ref.watch(authSessionProvider).asData?.value;
    final authState = ref.watch(authControllerProvider);
    final dashboardData = ref.watch(dashboardViewDataProvider);
    final sessionEmail = session?.email?.trim();
    final email = sessionEmail == null || sessionEmail.isEmpty
        ? 'Signed in user'
        : sessionEmail;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: FirstPaySpacing.small,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FirstPayLogo(fontSize: 21),
            SizedBox(width: FirstPaySpacing.small),
            Text('Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications are coming soon.')),
              );
            },
            icon: const Badge(child: Icon(Icons.notifications_outlined)),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile is coming soon.')),
              );
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: FirstPaySpacing.small),
        ],
      ),
      drawer: FirstPayDashboardDrawer(
        email: email,
        role: dashboardData.role.label,
        selectedDestination: _selectedDestination,
        onDestinationSelected: _selectDestination,
        isSigningOut: authState.isLoading,
        onLogout: authState.isLoading
            ? null
            : () {
                Navigator.of(context).pop();
                _signOut();
              },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 720
                ? FirstPaySpacing.xLarge
                : FirstPaySpacing.medium;
            final columnCount = constraints.maxWidth >= 1000
                ? 3
                : constraints.maxWidth >= 600
                ? 3
                : 2;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: FirstPaySpacing.large,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to FirstPay',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: FirstPayColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: FirstPaySpacing.small),
                      Text(
                        'Mandate operations across your Patsanstha network.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: FirstPayColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: FirstPaySpacing.large),
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: FirstPaySpacing.medium),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dashboardData.metrics.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnCount,
                          crossAxisSpacing: FirstPaySpacing.medium,
                          mainAxisSpacing: FirstPaySpacing.medium,
                          mainAxisExtent: 156,
                        ),
                        itemBuilder: (context, index) {
                          return DashboardSummaryCard(
                            metric: dashboardData.metrics[index],
                            icon: _metricIcons[index],
                          );
                        },
                      ),
                      const SizedBox(height: FirstPaySpacing.large),
                      DashboardUserCard(
                        email: email,
                        role: dashboardData.role,
                        lastLogin: dashboardData.lastLogin,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
