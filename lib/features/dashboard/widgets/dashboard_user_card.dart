import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/dashboard/domain/dashboard_view_data.dart';
import 'package:flutter/material.dart';

class DashboardUserCard extends StatelessWidget {
  const DashboardUserCard({
    required this.email,
    required this.role,
    required this.lastLogin,
    super.key,
  });

  final String email;
  final DashboardRole role;
  final String lastLogin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FirstPaySpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: FirstPayColors.primaryNavy,
                  foregroundColor: FirstPayColors.white,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: FirstPaySpacing.medium),
                Expanded(
                  child: Text(
                    'User information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FirstPaySpacing.large),
            _InformationRow(label: 'Email', value: email),
            const SizedBox(height: FirstPaySpacing.medium),
            _InformationRow(label: 'Current Role', value: role.label),
            const SizedBox(height: FirstPaySpacing.medium),
            _InformationRow(label: 'Last Login', value: lastLogin),
          ],
        ),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FirstPayColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
