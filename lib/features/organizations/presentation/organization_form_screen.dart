import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/features/organizations/application/organization_controller.dart';
import 'package:firstpay/features/organizations/domain/organization.dart';
import 'package:firstpay/features/organizations/domain/organization_repository.dart';
import 'package:firstpay/features/organizations/domain/organization_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrganizationFormScreen extends ConsumerStatefulWidget {
  const OrganizationFormScreen({this.organizationId, super.key});
  final String? organizationId;

  @override
  ConsumerState<OrganizationFormScreen> createState() =>
      _OrganizationFormScreenState();
}

class _OrganizationFormScreenState
    extends ConsumerState<OrganizationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _registrationNumber = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _contactPerson = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  DateTime? _registrationDate;
  OrganizationStatus _status = OrganizationStatus.active;
  Organization? _existing;
  bool _isLoading = false;
  String? _loadError;

  bool get _isNew => widget.organizationId == null;

  @override
  void initState() {
    super.initState();
    if (!_isNew) _loadOrganization();
  }

  Future<void> _loadOrganization() async {
    setState(() => _isLoading = true);
    try {
      final organization = await ref
          .read(organizationControllerProvider.notifier)
          .getOrganization(widget.organizationId!);
      if (!mounted) return;
      _existing = organization;
      _name.text = organization.name;
      _registrationNumber.text = organization.registrationNumber;
      _address.text = organization.address;
      _city.text = organization.city;
      _district.text = organization.district;
      _state.text = organization.state;
      _pincode.text = organization.pincode;
      _contactPerson.text = organization.contactPerson;
      _mobile.text = organization.mobile;
      _email.text = organization.email;
      setState(() {
        _registrationDate = organization.registrationDate;
        _status = organization.status;
        _isLoading = false;
      });
    } on OrganizationFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _registrationNumber,
      _address,
      _city,
      _district,
      _state,
      _pincode,
      _contactPerson,
      _mobile,
      _email,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(organizationControllerProvider).isSaving;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add Patsanstha' : 'Edit Patsanstha'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? Center(child: Text(_loadError!))
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(FirstPaySpacing.medium),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(FirstPaySpacing.large),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patsanstha details',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: FirstPaySpacing.large),
                              _field(_name, 'Name'),
                              _field(
                                _registrationNumber,
                                'Registration Number',
                              ),
                              _dateField(context),
                              _field(_address, 'Address', maxLines: 3),
                              _responsivePair(
                                _field(_city, 'City'),
                                _field(_district, 'District'),
                              ),
                              _responsivePair(
                                _field(_state, 'State'),
                                _field(
                                  _pincode,
                                  'PIN Code',
                                  validator: OrganizationValidators.pincode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                ),
                              ),
                              _field(_contactPerson, 'Contact Person'),
                              _responsivePair(
                                _field(
                                  _mobile,
                                  'Mobile',
                                  validator: OrganizationValidators.mobile,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                ),
                                _field(
                                  _email,
                                  'Email',
                                  validator: OrganizationValidators.email,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              DropdownButtonFormField<OrganizationStatus>(
                                initialValue: _status,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                ),
                                items: OrganizationStatus.values
                                    .map(
                                      (status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status.label),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: (value) {
                                  if (value != null) _status = value;
                                },
                              ),
                              const SizedBox(height: FirstPaySpacing.large),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: saving
                                        ? null
                                        : () => context.pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: FirstPaySpacing.small),
                                  FilledButton.icon(
                                    onPressed: saving ? null : _submit,
                                    icon: saving
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.save_outlined),
                                    label: Text(
                                      _isNew
                                          ? 'Add Patsanstha'
                                          : 'Save Changes',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: FirstPaySpacing.medium),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label),
      validator:
          validator ?? (value) => OrganizationValidators.required(value, label),
    ),
  );

  Widget _responsivePair(Widget first, Widget second) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 560) return Column(children: [first, second]);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: FirstPaySpacing.medium),
          Expanded(child: second),
        ],
      );
    },
  );

  Widget _dateField(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: FirstPaySpacing.medium),
    child: FormField<DateTime>(
      initialValue: _registrationDate,
      validator: (_) =>
          _registrationDate == null ? 'Registration Date is required' : null,
      builder: (field) => InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _registrationDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            setState(() => _registrationDate = date);
            field.didChange(date);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Registration Date',
            errorText: field.errorText,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(
            _registrationDate == null
                ? 'Select date'
                : '${_registrationDate!.day.toString().padLeft(2, '0')}/'
                      '${_registrationDate!.month.toString().padLeft(2, '0')}/'
                      '${_registrationDate!.year}',
          ),
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final organization = Organization(
      id: _existing?.id ?? '',
      tenantId: _existing?.tenantId ?? '',
      name: _name.text,
      registrationNumber: _registrationNumber.text,
      registrationDate: _registrationDate!,
      address: _address.text,
      city: _city.text,
      district: _district.text,
      state: _state.text,
      pincode: _pincode.text,
      contactPerson: _contactPerson.text,
      mobile: _mobile.text,
      email: _email.text,
      status: _status,
      createdAt: _existing?.createdAt,
      updatedAt: _existing?.updatedAt,
    );
    final error = await ref
        .read(organizationControllerProvider.notifier)
        .save(organization, isNew: _isNew);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.pop();
  }
}
