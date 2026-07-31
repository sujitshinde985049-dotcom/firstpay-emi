import 'package:firstpay/features/customers/domain/customer.dart';
import 'package:firstpay/features/customers/domain/customer_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCustomerRepository implements CustomerRepository {
  const SupabaseCustomerRepository(this._client);
  final SupabaseClient _client;
  @override
  Future<List<Customer>> getCustomers() async {
    try {
      final rows = await _client
          .from('customers')
          .select()
          .order('created_at', ascending: false);
      return rows.map(_fromJson).toList(growable: false);
    } on PostgrestException catch (e) {
      throw CustomerFailure(_message(e));
    } on Object {
      throw const CustomerFailure('Unable to load customers right now.');
    }
  }

  @override
  Future<Customer> getCustomer(String id) async {
    try {
      return _fromJson(
        await _client.from('customers').select().eq('id', id).single(),
      );
    } on PostgrestException catch (e) {
      throw CustomerFailure(_message(e));
    } on Object {
      throw const CustomerFailure('Unable to load this customer.');
    }
  }

  @override
  Future<Customer> createCustomer(Customer v) async {
    try {
      return _fromJson(
        await _client.from('customers').insert(_toJson(v)).select().single(),
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw const DuplicateCustomerMobileFailure();
      throw CustomerFailure(_message(e));
    } on Object {
      throw const CustomerFailure('Unable to add this customer.');
    }
  }

  @override
  Future<Customer> updateCustomer(Customer v) async {
    try {
      return _fromJson(
        await _client
            .from('customers')
            .update(_toJson(v))
            .eq('id', v.id)
            .select()
            .single(),
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw const DuplicateCustomerMobileFailure();
      throw CustomerFailure(_message(e));
    } on Object {
      throw const CustomerFailure('Unable to update this customer.');
    }
  }

  @override
  Future<void> updateStatus(String id, CustomerStatus status) async {
    try {
      await _client
          .from('customers')
          .update({'status': status.name})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw CustomerFailure(_message(e));
    } on Object {
      throw const CustomerFailure('Unable to change customer status.');
    }
  }

  @override
  Future<bool> mobileExists(
    String organizationId,
    String mobile, {
    String? excludeId,
  }) async {
    try {
      var q = _client
          .from('customers')
          .select('id')
          .eq('organization_id', organizationId)
          .eq('mobile', mobile.trim());
      if (excludeId != null) q = q.neq('id', excludeId);
      return (await q.limit(1)).isNotEmpty;
    } on PostgrestException catch (e) {
      throw CustomerFailure(_message(e));
    } on Object {
      throw const CustomerFailure('Unable to verify the mobile number.');
    }
  }

  Customer _fromJson(Map<String, dynamic> j) => Customer(
    id: j['id'] as String,
    organizationId: j['organization_id'] as String,
    fullName: j['full_name'] as String,
    mobile: j['mobile'] as String,
    email: j['email'] as String?,
    dateOfBirth: DateTime.parse(j['date_of_birth'] as String),
    gender: CustomerGender.values.byName(j['gender'] as String),
    aadhaarNumber: j['aadhaar_number'] as String?,
    panNumber: j['pan_number'] as String?,
    address: j['address'] as String,
    city: j['city'] as String,
    district: j['district'] as String,
    state: j['state'] as String,
    pincode: j['pincode'] as String,
    accountHolderName: j['account_holder_name'] as String,
    bankName: j['bank_name'] as String,
    branchName: j['branch_name'] as String,
    accountNumber: j['account_number'] as String,
    ifscCode: j['ifsc_code'] as String,
    accountType: BankAccountType.values.byName(j['account_type'] as String),
    upiId: j['upi_id'] as String?,
    status: CustomerStatus.values.byName(j['status'] as String),
    createdAt: DateTime.tryParse(j['created_at'] as String? ?? ''),
    updatedAt: DateTime.tryParse(j['updated_at'] as String? ?? ''),
  );
  Map<String, dynamic> _toJson(Customer v) => {
    'organization_id': v.organizationId,
    'full_name': v.fullName.trim(),
    'mobile': v.mobile.trim(),
    'email': _optional(v.email)?.toLowerCase(),
    'date_of_birth': v.dateOfBirth.toIso8601String().split('T').first,
    'gender': v.gender.name,
    'aadhaar_number': _optional(v.aadhaarNumber),
    'pan_number': _optional(v.panNumber)?.toUpperCase(),
    'address': v.address.trim(),
    'city': v.city.trim(),
    'district': v.district.trim(),
    'state': v.state.trim(),
    'pincode': v.pincode.trim(),
    'account_holder_name': v.accountHolderName.trim(),
    'bank_name': v.bankName.trim(),
    'branch_name': v.branchName.trim(),
    'account_number': v.accountNumber.trim(),
    'ifsc_code': v.ifscCode.trim().toUpperCase(),
    'account_type': v.accountType.name,
    'upi_id': _optional(v.upiId),
    'status': v.status.name,
  };
  String? _optional(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();
  String _message(PostgrestException e) => e.code == '42501'
      ? 'You do not have permission to manage customers.'
      : 'The customer request could not be completed.';
}
