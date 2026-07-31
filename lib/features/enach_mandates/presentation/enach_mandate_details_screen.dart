import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/features/enach_mandates/application/enach_mandate_controller.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EnachMandateDetailsScreen extends ConsumerWidget {
  const EnachMandateDetailsScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('e-NACH Mandate Details')),
      body: FutureBuilder<EnachMandate>(
        future: ref.read(enachMandateControllerProvider.notifier).get(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load e-NACH mandate.'));
          }
          final mandate = snapshot.requireData;
          final values = <String, String>{
            'Reference': mandate.referenceNumber,
            'Status': mandate.status.label,
            'Organization': mandate.organizationId,
            'Customer': mandate.customerId,
            'Account Holder': mandate.accountHolderName,
            'Bank': mandate.bankName,
            'Branch': mandate.branchName,
            'Account Number': mandate.accountNumber,
            'IFSC': mandate.ifscCode,
            'Account Type': mandate.accountType,
            'Maximum Debit':
                '₹${mandate.maximumDebitAmount.toStringAsFixed(2)}',
            'Frequency': mandate.frequency.label,
            'Start Date': mandate.startDate.toString().split(' ').first,
            'End Date': mandate.endDate.toString().split(' ').first,
            'Purpose': mandate.purpose,
            'Sponsor Bank': mandate.sponsorBank,
            'Destination Bank': mandate.destinationBank,
            'Authentication': mandate.authenticationMode.label,
            'Remarks': mandate.remarks ?? '—',
            'Created At': mandate.createdAt?.toLocal().toString() ?? '—',
            'Updated At': mandate.updatedAt?.toLocal().toString() ?? '—',
          };
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final entry in values.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 135, child: Text(entry.key)),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (mandate.status == EnachStatus.draft)
                FilledButton.icon(
                  onPressed: () =>
                      context.push(AppRoutes.editEnachMandatePath(mandate.id)),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Draft'),
                ),
            ],
          );
        },
      ),
    );
  }
}
