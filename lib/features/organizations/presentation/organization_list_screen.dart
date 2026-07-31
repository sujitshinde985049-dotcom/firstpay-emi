import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/organizations/application/organization_controller.dart';
import 'package:firstpay/features/organizations/domain/organization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrganizationListScreen extends ConsumerWidget {
  const OrganizationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(organizationControllerProvider);
    final controller = ref.read(organizationControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patsansthas'),
        leading: IconButton(
          tooltip: 'Back to Dashboard',
          onPressed: () => context.go(AppRoutes.dashboard),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addOrganization),
        icon: const Icon(Icons.add),
        label: const Text('Add Patsanstha'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(FirstPaySpacing.medium),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final search = TextField(
                    onChanged: controller.setSearchQuery,
                    decoration: const InputDecoration(
                      labelText: 'Search Patsansthas',
                      hintText: 'Name, registration number, city or contact',
                      prefixIcon: Icon(Icons.search),
                    ),
                  );
                  final filter = DropdownButtonFormField<OrganizationStatus?>(
                    initialValue: state.statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      DropdownMenuItem(
                        value: OrganizationStatus.active,
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: OrganizationStatus.inactive,
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: controller.setStatusFilter,
                  );
                  if (constraints.maxWidth < 640) {
                    return Column(
                      children: [
                        search,
                        const SizedBox(height: FirstPaySpacing.medium),
                        filter,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: search),
                      const SizedBox(width: FirstPaySpacing.medium),
                      SizedBox(width: 220, child: filter),
                    ],
                  );
                },
              ),
            ),
            Expanded(child: _OrganizationBody(state: state)),
          ],
        ),
      ),
    );
  }
}

class _OrganizationBody extends ConsumerWidget {
  const _OrganizationBody({required this.state});
  final OrganizationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.organizations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.organizations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(FirstPaySpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: FirstPaySpacing.medium),
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: FirstPaySpacing.medium),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(organizationControllerProvider.notifier).load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final organizations = state.filteredOrganizations;
    if (organizations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(FirstPaySpacing.large),
          child: Text('No Patsansthas match the selected filters.'),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(organizationControllerProvider.notifier).load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          FirstPaySpacing.medium,
          0,
          FirstPaySpacing.medium,
          96,
        ),
        itemCount: organizations.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: FirstPaySpacing.medium),
        itemBuilder: (context, index) =>
            _OrganizationCard(organization: organizations[index]),
      ),
    );
  }
}

class _OrganizationCard extends ConsumerWidget {
  const _OrganizationCard({required this.organization});
  final Organization organization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = organization.status == OrganizationStatus.active;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FirstPaySpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: FirstPayColors.primaryNavy,
                  foregroundColor: FirstPayColors.white,
                  child: Icon(Icons.account_balance_outlined),
                ),
                const SizedBox(width: FirstPaySpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organization.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: FirstPaySpacing.xSmall),
                      Text(
                        organization.registrationNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: FirstPayColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(organization.status.label),
                  backgroundColor:
                      (active
                              ? FirstPayColors.successGreen
                              : FirstPayColors.textSecondary)
                          .withValues(alpha: 0.1),
                ),
              ],
            ),
            const SizedBox(height: FirstPaySpacing.medium),
            Text('${organization.city}, ${organization.district}'),
            const SizedBox(height: FirstPaySpacing.xSmall),
            Text(
              '${organization.contactPerson} • ${organization.mobile}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FirstPayColors.textSecondary,
              ),
            ),
            const Divider(height: FirstPaySpacing.large),
            Wrap(
              spacing: FirstPaySpacing.small,
              children: [
                TextButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.editOrganizationPath(organization.id),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmStatusChange(context, ref),
                  icon: Icon(
                    active ? Icons.block_outlined : Icons.check_circle_outline,
                  ),
                  label: Text(active ? 'Deactivate' : 'Activate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmStatusChange(BuildContext context, WidgetRef ref) async {
    final active = organization.status == OrganizationStatus.active;
    final action = active ? 'Deactivate' : 'Activate';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Patsanstha?'),
        content: Text(
          '$action ${organization.name}? This changes its operational status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await ref
        .read(organizationControllerProvider.notifier)
        .toggleStatus(organization);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Patsanstha status updated.' : 'Unable to update status.',
        ),
      ),
    );
  }
}
