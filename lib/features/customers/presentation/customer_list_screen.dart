import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/customers/application/customer_controller.dart';
import 'package:firstpay/features/customers/domain/customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(customerControllerProvider);
    final c = ref.read(customerControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        leading: IconButton(
          tooltip: 'Back to Dashboard',
          onPressed: () => context.go(AppRoutes.dashboard),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addCustomer),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Customer'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(FirstPaySpacing.medium),
              child: LayoutBuilder(
                builder: (context, x) {
                  final search = TextField(
                    onChanged: c.setSearchQuery,
                    decoration: const InputDecoration(
                      labelText: 'Search Customers',
                      hintText: 'Name, mobile, Aadhaar, PAN or account',
                      prefixIcon: Icon(Icons.search),
                    ),
                  );
                  final filter = DropdownButtonFormField<CustomerStatus?>(
                    initialValue: s.statusFilter,
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
                        value: CustomerStatus.active,
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: CustomerStatus.inactive,
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: c.setStatusFilter,
                  );
                  return x.maxWidth < 640
                      ? Column(
                          children: [
                            search,
                            const SizedBox(height: 16),
                            filter,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: search),
                            const SizedBox(width: 16),
                            SizedBox(width: 220, child: filter),
                          ],
                        );
                },
              ),
            ),
            Expanded(child: _Body(state: s)),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});
  final CustomerState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.customers.isEmpty) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => ref.read(customerControllerProvider.notifier).load(),
          icon: const Icon(Icons.refresh),
          label: Text(state.errorMessage!),
        ),
      );
    }
    final items = state.filteredCustomers;
    if (items.isEmpty) {
      return const Center(
        child: Text('No customers match the selected filters.'),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(customerControllerProvider.notifier).load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _Card(customer: items[i]),
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card({required this.customer});
  final Customer customer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = customer.status == CustomerStatus.active;
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.customerDetailsPath(customer.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: FirstPayColors.primaryNavy,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.person_outline),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.fullName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          customer.mobile,
                          style: const TextStyle(
                            color: FirstPayColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(label: Text(customer.status.label)),
                ],
              ),
              const SizedBox(height: 8),
              Text('${customer.bankName} • ${customer.accountType.label}'),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.editCustomerPath(customer.id)),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => _toggle(context, ref),
                    icon: Icon(
                      active
                          ? Icons.block_outlined
                          : Icons.check_circle_outline,
                    ),
                    label: Text(active ? 'Deactivate' : 'Activate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final action = customer.status == CustomerStatus.active
        ? 'Deactivate'
        : 'Activate';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('$action Customer?'),
        content: Text('$action ${customer.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success = await ref
        .read(customerControllerProvider.notifier)
        .toggleStatus(customer);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Customer status updated.' : 'Unable to update status.',
          ),
        ),
      );
    }
  }
}
