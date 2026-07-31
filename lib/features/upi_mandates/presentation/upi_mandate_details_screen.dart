import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/upi_mandates/application/upi_mandate_controller.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UpiMandateDetailsScreen extends ConsumerWidget {
  const UpiMandateDetailsScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Mandate Details')),
    body: FutureBuilder<UpiMandate>(
      future: ref.read(upiMandateControllerProvider.notifier).get(id),
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.hasError) {
          return const Center(child: Text('Unable to load mandate.'));
        }
        final m = s.requireData;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(FirstPaySpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.referenceNumber,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    ...{
                      'Status': m.status.label,
                      'Organization': m.organizationId,
                      'Customer': m.customerId,
                      'Bank Account': m.bankAccount,
                      'UPI ID': m.upiId,
                      'Mandate Amount':
                          '₹${m.mandateAmount.toStringAsFixed(2)}',
                      'Maximum Amount':
                          '₹${m.maximumAmount.toStringAsFixed(2)}',
                      'Frequency': m.frequency.label,
                      'Start Date': m.startDate.toString().split(' ').first,
                      'End Date': m.endDate.toString().split(' ').first,
                      'Purpose': m.purpose,
                      'Created At': m.createdAt?.toLocal().toString() ?? '—',
                      'Updated At': m.updatedAt?.toLocal().toString() ?? '—',
                    }.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(width: 130, child: Text(e.key)),
                            Expanded(child: Text(e.value)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (m.status == MandateStatus.draft)
              FilledButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.editUpiMandatePath(m.id)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Draft'),
              ),
          ],
        );
      },
    ),
  );
}
