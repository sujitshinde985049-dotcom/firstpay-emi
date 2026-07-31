import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/features/enach_mandates/application/enach_mandate_controller.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EnachMandateListScreen extends ConsumerWidget {
  const EnachMandateListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(enachMandateControllerProvider),
        c = ref.read(enachMandateControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('e-NACH')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createEnachMandate),
        icon: const Icon(Icons.add),
        label: const Text('Create e-NACH Draft'),
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
                    labelText: 'Search e-NACH Mandates',
                    hintText: 'Reference, account holder, account or purpose',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<EnachStatus?>(
                  initialValue: s.statusFilter,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...EnachStatus.values.map(
                      (x) => DropdownMenuItem(value: x, child: Text(x.label)),
                    ),
                  ],
                  onChanged: c.filterStatus,
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
  final EnachMandateState state;
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
        child: Text('No e-NACH mandates match the selected filter.'),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(enachMandateControllerProvider.notifier).load(),
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
  final EnachMandate item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = item.status == EnachStatus.draft;
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.enachMandateDetailsPath(item.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.referenceNumber,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Chip(label: Text(item.status.label)),
                ],
              ),
              Text(
                '₹${item.maximumDebitAmount.toStringAsFixed(2)} • ${item.frequency.label}',
              ),
              Text('${item.accountHolderName} • ${item.bankName}'),
              if (draft)
                Wrap(
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.editEnachMandatePath(item.id)),
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
        title: const Text('Cancel e-NACH Draft?'),
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
      await ref.read(enachMandateControllerProvider.notifier).cancel(item);
    }
  }
}
