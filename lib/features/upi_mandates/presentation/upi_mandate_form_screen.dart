import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/customers/application/customer_controller.dart';
import 'package:firstpay/features/organizations/application/organization_controller.dart';
import 'package:firstpay/features/upi_mandates/application/upi_mandate_controller.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UpiMandateFormScreen extends ConsumerStatefulWidget {
  const UpiMandateFormScreen({this.id, super.key});
  final String? id;
  @override
  ConsumerState<UpiMandateFormScreen> createState() => _State();
}

class _State extends ConsumerState<UpiMandateFormScreen> {
  final key = GlobalKey<FormState>();
  final upi = TextEditingController(),
      amount = TextEditingController(),
      maximum = TextEditingController(),
      purpose = TextEditingController();
  String? organizationId, customerId;
  String bankAccount = '';
  MandateFrequency frequency = MandateFrequency.monthly;
  DateTime? start, end;
  UpiMandate? existing;
  bool loading = false;
  String? error;
  bool get isNew => widget.id == null;
  @override
  void initState() {
    super.initState();
    if (!isNew) _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final m = await ref
          .read(upiMandateControllerProvider.notifier)
          .get(widget.id!);
      if (!mounted) return;
      if (m.status != MandateStatus.draft) {
        setState(() {
          error = 'Only draft mandates can be edited.';
          loading = false;
        });
        return;
      }
      existing = m;
      organizationId = m.organizationId;
      customerId = m.customerId;
      bankAccount = m.bankAccount;
      upi.text = m.upiId;
      amount.text = m.mandateAmount.toString();
      maximum.text = m.maximumAmount.toString();
      purpose.text = m.purpose;
      setState(() {
        frequency = m.frequency;
        start = m.startDate;
        end = m.endDate;
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Unable to load this draft.';
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    upi.dispose();
    amount.dispose();
    maximum.dispose();
    purpose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orgs = ref.watch(organizationControllerProvider).organizations;
    final customers = ref
        .watch(customerControllerProvider)
        .customers
        .where(
          (c) => organizationId == null || c.organizationId == organizationId,
        )
        .toList();
    final saving = ref.watch(upiMandateControllerProvider).saving;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Create UPI Mandate' : 'Edit UPI Mandate Draft'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Form(
              key: key,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(FirstPaySpacing.large),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: organizationId,
                            decoration: const InputDecoration(
                              labelText: 'Organization',
                            ),
                            items: orgs
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o.id,
                                    child: Text(o.name),
                                  ),
                                )
                                .toList(),
                            validator: (v) =>
                                v == null ? 'Organization is required' : null,
                            onChanged: (v) => setState(() {
                              organizationId = v;
                              customerId = null;
                              bankAccount = '';
                            }),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: customerId,
                            decoration: const InputDecoration(
                              labelText: 'Customer',
                            ),
                            items: customers
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text('${c.fullName} • ${c.mobile}'),
                                  ),
                                )
                                .toList(),
                            validator: (v) =>
                                v == null ? 'Customer is required' : null,
                            onChanged: (v) {
                              final c = customers
                                  .where((x) => x.id == v)
                                  .firstOrNull;
                              setState(() {
                                customerId = v;
                                bankAccount = c?.accountNumber ?? '';
                                upi.text = c?.upiId ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: bankAccount,
                            key: ValueKey(bankAccount),
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Bank Account',
                            ),
                            validator: (v) => UpiMandateValidators.required(
                              v,
                              'Bank Account',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: upi,
                            decoration: const InputDecoration(
                              labelText: 'UPI ID',
                            ),
                            validator: UpiMandateValidators.upiId,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: amount,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Mandate Amount',
                                  ),
                                  validator: (v) => UpiMandateValidators.amount(
                                    v,
                                    'Mandate Amount',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: maximum,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Maximum Amount',
                                  ),
                                  validator: (v) {
                                    final r = UpiMandateValidators.amount(
                                      v,
                                      'Maximum Amount',
                                    );
                                    if (r != null) return r;
                                    final a = double.tryParse(amount.text),
                                        m = double.tryParse(v!);
                                    return a != null && m != null && m < a
                                        ? 'Maximum Amount must be at least the Mandate Amount'
                                        : null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<MandateFrequency>(
                            initialValue: frequency,
                            decoration: const InputDecoration(
                              labelText: 'Frequency',
                            ),
                            items: MandateFrequency.values
                                .map(
                                  (x) => DropdownMenuItem(
                                    value: x,
                                    child: Text(x.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) frequency = v;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _date(
                                  context,
                                  'Start Date',
                                  start,
                                  (v) => setState(() => start = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _date(
                                  context,
                                  'End Date',
                                  end,
                                  (v) => setState(() => end = v),
                                ),
                              ),
                            ],
                          ),
                          if (UpiMandateValidators.dates(start, end) != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                UpiMandateValidators.dates(start, end)!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: purpose,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Purpose',
                            ),
                            validator: (v) =>
                                UpiMandateValidators.required(v, 'Purpose'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: saving ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: saving ? null : _submit,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Draft'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _date(
    BuildContext c,
    String label,
    DateTime? value,
    ValueChanged<DateTime> set,
  ) => FormField<DateTime>(
    validator: (_) => value == null ? '$label is required' : null,
    builder: (f) => InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: c,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (d != null) {
          set(d);
          f.didChange(d);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, errorText: f.errorText),
        child: Text(value?.toString().split(' ').first ?? 'Select date'),
      ),
    ),
  );
  Future<void> _submit() async {
    if (!(key.currentState?.validate() ?? false) ||
        UpiMandateValidators.dates(start, end) != null) {
      setState(() {});
      return;
    }
    final m = UpiMandate(
      id: existing?.id ?? '',
      referenceNumber: existing?.referenceNumber ?? '',
      organizationId: organizationId!,
      customerId: customerId!,
      bankAccount: bankAccount,
      upiId: upi.text,
      mandateAmount: double.parse(amount.text),
      maximumAmount: double.parse(maximum.text),
      frequency: frequency,
      startDate: start!,
      endDate: end!,
      purpose: purpose.text,
      status: MandateStatus.draft,
      createdAt: existing?.createdAt,
      updatedAt: existing?.updatedAt,
    );
    final e = await ref
        .read(upiMandateControllerProvider.notifier)
        .save(m, isNew: isNew);
    if (!mounted) return;
    if (e == null) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
    }
  }
}
