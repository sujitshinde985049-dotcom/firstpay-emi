import 'package:firstpay/app/localization/app_strings.dart';
import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/core/widgets/firstpay_logo.dart';
import 'package:firstpay/core/widgets/foundation_states.dart';
import 'package:flutter/material.dart';

class DesignSystemPreviewScreen extends StatelessWidget {
  const DesignSystemPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const FirstPayLogo()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(FirstPaySpacing.medium),
          children: [
            Text(
              AppStrings.previewTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: FirstPayColors.textPrimary,
              ),
            ),
            const SizedBox(height: FirstPaySpacing.small),
            const Text(AppStrings.tagline),
            const SizedBox(height: FirstPaySpacing.large),
            const _PreviewCard(),
            const SizedBox(height: FirstPaySpacing.medium),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                hintText: 'Search synchronized records',
              ),
            ),
            const SizedBox(height: FirstPaySpacing.medium),
            Wrap(
              spacing: FirstPaySpacing.small,
              runSpacing: FirstPaySpacing.small,
              children: [
                FilledButton(
                  onPressed: () {},
                  child: const Text('Primary action'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Secondary action'),
                ),
                FilledButton.tonal(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    foregroundColor: FirstPayColors.error,
                  ),
                  child: const Text('Destructive action'),
                ),
              ],
            ),
            const SizedBox(height: FirstPaySpacing.large),
            const OfflineState(),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(FirstPaySpacing.medium),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.account_balance_outlined)),
          const SizedBox(width: FirstPaySpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Patsanstha',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text('Read-only synchronized preview'),
              ],
            ),
          ),
          const Chip(label: Text('ACTIVE')),
        ],
      ),
    ),
  );
}
