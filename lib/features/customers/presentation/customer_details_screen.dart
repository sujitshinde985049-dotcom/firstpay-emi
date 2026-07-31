import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/customers/application/customer_controller.dart';
import 'package:firstpay/features/customers/domain/customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  const CustomerDetailsScreen({required this.customerId, super.key});
  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            tooltip: 'Edit Customer',
            onPressed: () =>
                context.push(AppRoutes.editCustomerPath(customerId)),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: FutureBuilder<Customer>(
        future: ref
            .read(customerControllerProvider.notifier)
            .getCustomer(customerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load customer details.'),
            );
          }
          final customer = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.all(FirstPaySpacing.medium),
            children: [
              _section(context, 'Customer', {
                'Customer ID': customer.id,
                'Full Name': customer.fullName,
                'Mobile': customer.mobile,
                'Email': customer.email ?? '—',
                'Date of Birth': _date(customer.dateOfBirth),
                'Gender': customer.gender.label,
                'Status': customer.status.label,
              }),
              const SizedBox(height: FirstPaySpacing.medium),
              _section(context, 'Identity', {
                'Aadhaar': customer.aadhaarNumber ?? '—',
                'PAN': customer.panNumber ?? '—',
              }),
              const SizedBox(height: FirstPaySpacing.medium),
              _section(context, 'Address', {
                'Address': customer.address,
                'City': customer.city,
                'District': customer.district,
                'State': customer.state,
                'PIN Code': customer.pincode,
              }),
              const SizedBox(height: FirstPaySpacing.medium),
              _section(context, 'Bank Details', {
                'Account Holder': customer.accountHolderName,
                'Bank': customer.bankName,
                'Branch': customer.branchName,
                'Account Number': customer.accountNumber,
                'IFSC': customer.ifscCode,
                'Account Type': customer.accountType.label,
                'UPI ID': customer.upiId ?? '—',
              }),
              const SizedBox(height: FirstPaySpacing.medium),
              _section(context, 'Audit', {
                'Created At': customer.createdAt?.toLocal().toString() ?? '—',
                'Updated At': customer.updatedAt?.toLocal().toString() ?? '—',
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    Map<String, String> values,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FirstPaySpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Divider(),
            for (final entry in values.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 125, child: Text(entry.key)),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
