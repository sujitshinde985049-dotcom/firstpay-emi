import 'package:firstpay/app/localization/app_strings.dart';
import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Loading'});
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(label: label, child: const CircularProgressIndicator()),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) =>
      _MessageState(icon: Icons.inbox_outlined, title: title, message: message);
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _MessageState(
    icon: Icons.error_outline,
    iconColor: FirstPayColors.error,
    title: 'Something went wrong',
    message: message,
    action: onRetry == null
        ? null
        : FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
  );
}

class OfflineState extends StatelessWidget {
  const OfflineState({super.key});

  @override
  Widget build(BuildContext context) => const _MessageState(
    icon: Icons.cloud_off_outlined,
    iconColor: FirstPayColors.warning,
    title: AppStrings.offlineTitle,
    message: AppStrings.offlineMessage,
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor,
    this.action,
  });
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(FirstPaySpacing.large),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: iconColor ?? FirstPayColors.textSecondary),
        const SizedBox(height: FirstPaySpacing.medium),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FirstPaySpacing.small),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: FirstPayColors.textSecondary),
        ),
        if (action != null) ...[
          const SizedBox(height: FirstPaySpacing.medium),
          action!,
        ],
      ],
    ),
  );
}
