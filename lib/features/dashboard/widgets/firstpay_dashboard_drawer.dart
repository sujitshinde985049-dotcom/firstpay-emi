import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/core/widgets/firstpay_logo.dart';
import 'package:firstpay/features/dashboard/presentation/dashboard_destination.dart';
import 'package:flutter/material.dart';

class FirstPayDashboardDrawer extends StatelessWidget {
  const FirstPayDashboardDrawer({
    required this.email,
    required this.role,
    required this.selectedDestination,
    required this.onDestinationSelected,
    required this.onLogout,
    required this.isSigningOut,
    super.key,
  });

  final String email;
  final String role;
  final DashboardDestination selectedDestination;
  final ValueChanged<DashboardDestination> onDestinationSelected;
  final VoidCallback? onLogout;
  final bool isSigningOut;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(FirstPaySpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FirstPayLogo(),
                  const SizedBox(height: FirstPaySpacing.large),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: FirstPayColors.primaryNavy,
                        foregroundColor: FirstPayColors.white,
                        child: Icon(Icons.person_outline),
                      ),
                      const SizedBox(width: FirstPaySpacing.medium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: FirstPaySpacing.xSmall),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: FirstPayColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: FirstPaySpacing.small,
                ),
                children: [
                  for (final destination in DashboardDestination.values)
                    ListTile(
                      leading: Icon(destination.icon),
                      title: Text(destination.label),
                      selected: destination == selectedDestination,
                      selectedColor: FirstPayColors.primaryNavy,
                      selectedTileColor: FirstPayColors.primaryNavy.withValues(
                        alpha: 0.08,
                      ),
                      onTap: () => onDestinationSelected(destination),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: isSigningOut
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              title: const Text('Logout'),
              enabled: !isSigningOut,
              onTap: onLogout,
            ),
            const SizedBox(height: FirstPaySpacing.small),
          ],
        ),
      ),
    );
  }
}
