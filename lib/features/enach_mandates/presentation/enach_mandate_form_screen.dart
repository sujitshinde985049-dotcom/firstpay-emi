import 'package:firstpay/features/customers/application/customer_controller.dart';
import 'package:firstpay/features/enach_mandates/application/enach_mandate_controller.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate_validators.dart';
import 'package:firstpay/features/organizations/application/organization_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EnachMandateFormScreen extends ConsumerStatefulWidget {
  const EnachMandateFormScreen({this.id, super.key});
  final String? id;
  @override
  ConsumerState<EnachMandateFormScreen> createState() => _State();
}

class _State extends ConsumerState<EnachMandateFormScreen> {
  final key = GlobalKey<FormState>();
  final f = {
    for (final k in [
      'holder',
      'bank',
      'branch',
      'account',
      'ifsc',
      'amount',
      'purpose',
      'sponsor',
      'destination',
      'remarks',
    ])
      k: TextEditingController(),
  };
  String? organizationId, customerId;
  String accountType = 'savings';
  EnachFrequency frequency = EnachFrequency.monthly;
  EnachAuthenticationMode auth = EnachAuthenticationMode.netBanking;
  DateTime? start, end;
  EnachMandate? existing;
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
          .read(enachMandateControllerProvider.notifier)
          .get(widget.id!);
      if (!mounted) return;
      if (m.status != EnachStatus.draft) {
        setState(() {
          error = 'Only draft e-NACH mandates can be edited.';
          loading = false;
        });
        return;
      }
      existing = m;
      organizationId = m.organizationId;
      customerId = m.customerId;
      f['holder']!.text = m.accountHolderName;
      f['bank']!.text = m.bankName;
      f['branch']!.text = m.branchName;
      f['account']!.text = m.accountNumber;
      f['ifsc']!.text = m.ifscCode;
      f['amount']!.text = m.maximumDebitAmount.toString();
      f['purpose']!.text = m.purpose;
      f['sponsor']!.text = m.sponsorBank;
      f['destination']!.text = m.destinationBank;
      f['remarks']!.text = m.remarks ?? '';
      setState(() {
        accountType = m.accountType;
        frequency = m.frequency;
        auth = m.authenticationMode;
        start = m.startDate;
        end = m.endDate;
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Unable to load this e-NACH draft.';
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in f.values) {
      c.dispose();
    }
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
    final saving = ref.watch(enachMandateControllerProvider).saving;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Create e-NACH Draft' : 'Edit e-NACH Draft'),
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
                      padding: const EdgeInsets.all(16),
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
                                if (c != null) {
                                  f['holder']!.text = c.accountHolderName;
                                  f['bank']!.text = c.bankName;
                                  f['branch']!.text = c.branchName;
                                  f['account']!.text = c.accountNumber;
                                  f['ifsc']!.text = c.ifscCode;
                                  accountType = c.accountType.name;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _field('holder', 'Account Holder Name'),
                          _pair(
                            _field('bank', 'Bank Name'),
                            _field('branch', 'Branch Name'),
                          ),
                          _pair(
                            _field(
                              'account',
                              'Account Number',
                              validator: EnachMandateValidators.account,
                              digits: 18,
                            ),
                            _field(
                              'ifsc',
                              'IFSC Code',
                              validator: EnachMandateValidators.ifsc,
                              uppercase: true,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: accountType,
                            decoration: const InputDecoration(
                              labelText: 'Account Type',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'savings',
                                child: Text('Savings'),
                              ),
                              DropdownMenuItem(
                                value: 'current',
                                child: Text('Current'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) accountType = v;
                            },
                          ),
                          const SizedBox(height: 16),
                          _field(
                            'amount',
                            'Maximum Debit Amount',
                            validator: EnachMandateValidators.amount,
                          ),
                          DropdownButtonFormField<EnachFrequency>(
                            initialValue: frequency,
                            decoration: const InputDecoration(
                              labelText: 'Debit Frequency',
                            ),
                            items: EnachFrequency.values
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
                          if (EnachMandateValidators.dates(start, end) != null)
                            Text(
                              EnachMandateValidators.dates(start, end)!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          const SizedBox(height: 16),
                          _field('purpose', 'Purpose', lines: 3),
                          _pair(
                            _field('sponsor', 'Sponsor Bank (placeholder)'),
                            _field(
                              'destination',
                              'Destination Bank (placeholder)',
                            ),
                          ),
                          DropdownButtonFormField<EnachAuthenticationMode>(
                            initialValue: auth,
                            decoration: const InputDecoration(
                              labelText: 'Authentication Mode',
                            ),
                            items: EnachAuthenticationMode.values
                                .map(
                                  (x) => DropdownMenuItem(
                                    value: x,
                                    child: Text(x.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) auth = v;
                            },
                          ),
                          const SizedBox(height: 16),
                          _field(
                            'remarks',
                            'Remarks',
                            lines: 3,
                            required: false,
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

  Widget _field(
    String k,
    String label, {
    String? Function(String?)? validator,
    int? digits,
    int lines = 1,
    bool uppercase = false,
    bool required = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: f[k],
      maxLines: lines,
      inputFormatters: [
        if (digits != null) FilteringTextInputFormatter.digitsOnly,
        if (digits != null) LengthLimitingTextInputFormatter(digits),
        if (uppercase) _Upper(),
      ],
      decoration: InputDecoration(labelText: label),
      validator:
          validator ??
          (required ? (v) => EnachMandateValidators.required(v, label) : null),
    ),
  );
  Widget _pair(Widget a, Widget b) => LayoutBuilder(
    builder: (c, x) => x.maxWidth < 560
        ? Column(children: [a, b])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ],
          ),
  );
  Widget _date(
    BuildContext c,
    String label,
    DateTime? v,
    ValueChanged<DateTime> set,
  ) => FormField<DateTime>(
    validator: (_) => v == null ? '$label is required' : null,
    builder: (field) => InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: c,
          initialDate: v ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (d != null) {
          set(d);
          field.didChange(d);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: field.errorText,
        ),
        child: Text(v?.toString().split(' ').first ?? 'Select date'),
      ),
    ),
  );
  Future<void> _submit() async {
    if (!(key.currentState?.validate() ?? false) ||
        EnachMandateValidators.dates(start, end) != null) {
      setState(() {});
      return;
    }
    final m = EnachMandate(
      id: existing?.id ?? '',
      referenceNumber: existing?.referenceNumber ?? '',
      organizationId: organizationId!,
      customerId: customerId!,
      accountHolderName: f['holder']!.text,
      bankName: f['bank']!.text,
      branchName: f['branch']!.text,
      accountNumber: f['account']!.text,
      ifscCode: f['ifsc']!.text,
      accountType: accountType,
      maximumDebitAmount: double.parse(f['amount']!.text),
      frequency: frequency,
      startDate: start!,
      endDate: end!,
      purpose: f['purpose']!.text,
      sponsorBank: f['sponsor']!.text,
      destinationBank: f['destination']!.text,
      authenticationMode: auth,
      status: EnachStatus.draft,
      remarks: f['remarks']!.text,
      createdAt: existing?.createdAt,
      updatedAt: existing?.updatedAt,
    );
    final e = await ref
        .read(enachMandateControllerProvider.notifier)
        .save(m, isNew: isNew);
    if (!mounted) return;
    if (e == null) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
    }
  }
}

class _Upper extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
