import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/customers/application/customer_controller.dart';
import 'package:firstpay/features/customers/domain/customer.dart';
import 'package:firstpay/features/customers/domain/customer_repository.dart';
import 'package:firstpay/features/customers/domain/customer_validators.dart';
import 'package:firstpay/features/organizations/application/organization_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({this.customerId, super.key});
  final String? customerId;
  @override
  ConsumerState<CustomerFormScreen> createState() => _State();
}

class _State extends ConsumerState<CustomerFormScreen> {
  final key = GlobalKey<FormState>();
  final fields = {
    for (final k in [
      'fullName',
      'mobile',
      'email',
      'aadhaar',
      'pan',
      'address',
      'city',
      'district',
      'state',
      'pincode',
      'holder',
      'bank',
      'branch',
      'account',
      'ifsc',
      'upi',
    ])
      k: TextEditingController(),
  };
  String? organizationId;
  DateTime? dob;
  CustomerGender gender = CustomerGender.preferNotToSay;
  BankAccountType accountType = BankAccountType.savings;
  CustomerStatus status = CustomerStatus.active;
  Customer? existing;
  bool loading = false;
  String? error;
  bool get isNew => widget.customerId == null;
  @override
  void initState() {
    super.initState();
    if (!isNew) _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final c = await ref
          .read(customerControllerProvider.notifier)
          .getCustomer(widget.customerId!);
      if (!mounted) return;
      existing = c;
      organizationId = c.organizationId;
      fields['fullName']!.text = c.fullName;
      fields['mobile']!.text = c.mobile;
      fields['email']!.text = c.email ?? '';
      fields['aadhaar']!.text = c.aadhaarNumber ?? '';
      fields['pan']!.text = c.panNumber ?? '';
      fields['address']!.text = c.address;
      fields['city']!.text = c.city;
      fields['district']!.text = c.district;
      fields['state']!.text = c.state;
      fields['pincode']!.text = c.pincode;
      fields['holder']!.text = c.accountHolderName;
      fields['bank']!.text = c.bankName;
      fields['branch']!.text = c.branchName;
      fields['account']!.text = c.accountNumber;
      fields['ifsc']!.text = c.ifscCode;
      fields['upi']!.text = c.upiId ?? '';
      setState(() {
        dob = c.dateOfBirth;
        gender = c.gender;
        accountType = c.accountType;
        status = c.status;
        loading = false;
      });
    } on CustomerFailure catch (e) {
      if (mounted) {
        setState(() {
          error = e.message;
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(customerControllerProvider).isSaving;
    final orgs = ref.watch(organizationControllerProvider).organizations;
    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'Add Customer' : 'Edit Customer')),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text(error!))
            : Form(
                key: key,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _section(context, 'Customer Information', [
                      DropdownButtonFormField<String>(
                        initialValue: organizationId,
                        decoration: const InputDecoration(
                          labelText: 'Patsanstha',
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
                            v == null ? 'Patsanstha is required' : null,
                        onChanged: (v) => organizationId = v,
                      ),
                      _f('fullName', 'Full Name'),
                      _pair(
                        _f(
                          'mobile',
                          'Mobile Number',
                          validator: CustomerValidators.mobile,
                          digits: 10,
                        ),
                        _f(
                          'email',
                          'Email (optional)',
                          validator: CustomerValidators.email,
                        ),
                      ),
                      _date(context),
                      DropdownButtonFormField<CustomerGender>(
                        initialValue: gender,
                        decoration: const InputDecoration(labelText: 'Gender'),
                        items: CustomerGender.values
                            .map(
                              (x) => DropdownMenuItem(
                                value: x,
                                child: Text(x.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) gender = v;
                        },
                      ),
                    ]),
                    _section(context, 'Identity', [
                      _pair(
                        _f(
                          'aadhaar',
                          'Aadhaar Number (optional)',
                          validator: CustomerValidators.aadhaar,
                          digits: 12,
                        ),
                        _f(
                          'pan',
                          'PAN Number (optional)',
                          validator: CustomerValidators.pan,
                          uppercase: true,
                        ),
                      ),
                    ]),
                    _section(context, 'Address', [
                      _f('address', 'Address', lines: 3),
                      _pair(_f('city', 'City'), _f('district', 'District')),
                      _pair(
                        _f('state', 'State'),
                        _f(
                          'pincode',
                          'PIN Code',
                          validator: CustomerValidators.pincode,
                          digits: 6,
                        ),
                      ),
                    ]),
                    _section(context, 'Bank Details', [
                      _f('holder', 'Account Holder Name'),
                      _pair(
                        _f('bank', 'Bank Name'),
                        _f('branch', 'Branch Name'),
                      ),
                      _pair(
                        _f(
                          'account',
                          'Account Number',
                          validator: CustomerValidators.accountNumber,
                          digits: 18,
                        ),
                        _f(
                          'ifsc',
                          'IFSC Code',
                          validator: CustomerValidators.ifsc,
                          uppercase: true,
                        ),
                      ),
                      DropdownButtonFormField<BankAccountType>(
                        initialValue: accountType,
                        decoration: const InputDecoration(
                          labelText: 'Account Type',
                        ),
                        items: BankAccountType.values
                            .map(
                              (x) => DropdownMenuItem(
                                value: x,
                                child: Text(x.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) accountType = v;
                        },
                      ),
                      const SizedBox(height: 16),
                      _f('upi', 'UPI ID (optional)', required: false),
                      DropdownButtonFormField<CustomerStatus>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: CustomerStatus.values
                            .map(
                              (x) => DropdownMenuItem(
                                value: x,
                                child: Text(x.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) status = v;
                        },
                      ),
                    ]),
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
                          label: Text(isNew ? 'Add Customer' : 'Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _section(BuildContext c, String title, List<Widget> children) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(FirstPaySpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              c,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );
  Widget _f(
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
      controller: fields[k],
      maxLines: lines,
      inputFormatters: [
        if (digits != null) FilteringTextInputFormatter.digitsOnly,
        if (digits != null) LengthLimitingTextInputFormatter(digits),
        if (uppercase) UpperCaseFormatter(),
      ],
      decoration: InputDecoration(labelText: label),
      validator:
          validator ??
          (required ? (v) => CustomerValidators.required(v, label) : null),
    ),
  );
  Widget _pair(Widget a, Widget b) => LayoutBuilder(
    builder: (c, x) => x.maxWidth < 560
        ? Column(children: [a, b])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 16),
              Expanded(child: b),
            ],
          ),
  );
  Widget _date(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: FormField<DateTime>(
      validator: (_) => dob == null ? 'Date of Birth is required' : null,
      builder: (f) => InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: dob ?? DateTime(1990),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (d != null) {
            setState(() => dob = d);
            f.didChange(d);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            errorText: f.errorText,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(
            dob == null
                ? 'Select date'
                : '${dob!.day}/${dob!.month}/${dob!.year}',
          ),
        ),
      ),
    ),
  );
  Future<void> _submit() async {
    if (!(key.currentState?.validate() ?? false)) return;
    final v = Customer(
      id: existing?.id ?? '',
      organizationId: organizationId!,
      fullName: fields['fullName']!.text,
      mobile: fields['mobile']!.text,
      email: fields['email']!.text,
      dateOfBirth: dob!,
      gender: gender,
      aadhaarNumber: fields['aadhaar']!.text,
      panNumber: fields['pan']!.text,
      address: fields['address']!.text,
      city: fields['city']!.text,
      district: fields['district']!.text,
      state: fields['state']!.text,
      pincode: fields['pincode']!.text,
      accountHolderName: fields['holder']!.text,
      bankName: fields['bank']!.text,
      branchName: fields['branch']!.text,
      accountNumber: fields['account']!.text,
      ifscCode: fields['ifsc']!.text,
      accountType: accountType,
      upiId: fields['upi']!.text,
      status: status,
      createdAt: existing?.createdAt,
      updatedAt: existing?.updatedAt,
    );
    final e = await ref
        .read(customerControllerProvider.notifier)
        .save(v, isNew: isNew);
    if (!mounted) return;
    if (e == null) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
    }
  }
}

class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
