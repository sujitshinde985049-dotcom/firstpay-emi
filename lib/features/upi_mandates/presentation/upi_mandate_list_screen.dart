import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/upi_mandates/application/upi_mandate_controller.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UpiMandateListScreen extends ConsumerWidget {
  const UpiMandateListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(upiMandateControllerProvider),
        c = ref.read(upiMandateControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('UPI AutoPay')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createUpiMandate),
        icon: const Icon(Icons.add),
        label: const Text('Create Mandate'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: c.search,
                  decoration: const InputDecoration(
                    labelText: 'Search Mandates',
                    hintText: 'Reference, UPI ID, purpose or account',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<MandateStatus?>(
                        initialValue: s.statusFilter,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All'),
                          ),
                          ...MandateStatus.values.map(
                            (x) => DropdownMenuItem(
                              value: x,
                              child: Text(x.label),
                            ),
                          ),
                        ],
                        onChanged: c.filterStatus,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<MandateFrequency?>(
                        initialValue: s.frequencyFilter,
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All'),
                          ),
                          ...MandateFrequency.values.map(
                            (x) => DropdownMenuItem(
                              value: x,
                              child: Text(x.label),
                            ),
                          ),
                        ],
                        onChanged: c.filterFrequency,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _Body(state: s)),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});
  final UpiMandateState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(child: Text(state.error!));
    }
    final items = state.filtered;
    if (items.isEmpty) {
      return const Center(
        child: Text('No UPI mandates match the selected filters.'),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(upiMandateControllerProvider.notifier).load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _Card(item: items[i]),
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card({required this.item});
  final UpiMandate item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = item.status == MandateStatus.draft;
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.upiMandateDetailsPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.all(FirstPaySpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.referenceNumber,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Chip(label: Text(item.status.label)),
                ],
              ),
              Text(
                '₹${item.mandateAmount.toStringAsFixed(2)} • ${item.frequency.label}',
              ),
              Text(item.upiId),
              if (draft)
                Wrap(
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.editUpiMandatePath(item.id)),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Draft'),
                    ),
                    TextButton.icon(
                      onPressed: () => _cancel(context, ref),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Draft'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cancel Draft?'),
        content: const Text('This draft cannot be edited after cancellation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep Draft'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Cancel Draft'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(upiMandateControllerProvider.notifier).cancel(item);
    }
  }
}
