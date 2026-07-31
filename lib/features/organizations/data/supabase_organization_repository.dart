import 'package:firstpay/features/organizations/domain/organization.dart';
import 'package:firstpay/features/organizations/domain/organization_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrganizationRepository implements OrganizationRepository {
  const SupabaseOrganizationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Organization>> getOrganizations() async {
    try {
      final rows = await _client
          .from('organizations')
          .select()
          .order('created_at', ascending: false);
      return rows.map(_fromJson).toList(growable: false);
    } on PostgrestException catch (error) {
      throw OrganizationFailure(_messageFor(error));
    } on Object {
      throw const OrganizationFailure('Unable to load Patsansthas right now.');
    }
  }

  @override
  Future<Organization> getOrganization(String id) async {
    try {
      final row = await _client
          .from('organizations')
          .select()
          .eq('id', id)
          .single();
      return _fromJson(row);
    } on PostgrestException catch (error) {
      throw OrganizationFailure(_messageFor(error));
    } on Object {
      throw const OrganizationFailure('Unable to load this Patsanstha.');
    }
  }

  @override
  Future<Organization> createOrganization(Organization organization) async {
    try {
      final row = await _client
          .from('organizations')
          .insert(_toJson(organization))
          .select()
          .single();
      return _fromJson(row);
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const DuplicateRegistrationNumberFailure();
      }
      throw OrganizationFailure(_messageFor(error));
    } on Object {
      throw const OrganizationFailure('Unable to add this Patsanstha.');
    }
  }

  @override
  Future<Organization> updateOrganization(Organization organization) async {
    try {
      final row = await _client
          .from('organizations')
          .update(_toJson(organization))
          .eq('id', organization.id)
          .select()
          .single();
      return _fromJson(row);
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const DuplicateRegistrationNumberFailure();
      }
      throw OrganizationFailure(_messageFor(error));
    } on Object {
      throw const OrganizationFailure('Unable to update this Patsanstha.');
    }
  }

  @override
  Future<void> updateStatus(String id, OrganizationStatus status) async {
    try {
      await _client
          .from('organizations')
          .update({'status': status.name})
          .eq('id', id);
    } on PostgrestException catch (error) {
      throw OrganizationFailure(_messageFor(error));
    } on Object {
      throw const OrganizationFailure('Unable to change Patsanstha status.');
    }
  }

  @override
  Future<bool> registrationNumberExists(
    String registrationNumber, {
    String? excludeId,
  }) async {
    try {
      var query = _client
          .from('organizations')
          .select('id')
          .ilike('registration_number', registrationNumber.trim());
      if (excludeId != null) query = query.neq('id', excludeId);
      final rows = await query.limit(1);
      return rows.isNotEmpty;
    } on PostgrestException catch (error) {
      throw OrganizationFailure(_messageFor(error));
    } on Object {
      throw const OrganizationFailure(
        'Unable to verify the registration number.',
      );
    }
  }

  Organization _fromJson(Map<String, dynamic> json) => Organization(
    id: json['id'] as String,
    tenantId: json['tenant_id'] as String,
    name: json['name'] as String,
    registrationNumber: json['registration_number'] as String,
    registrationDate: DateTime.parse(json['registration_date'] as String),
    address: json['address'] as String,
    city: json['city'] as String,
    district: json['district'] as String,
    state: json['state'] as String,
    pincode: json['pincode'] as String,
    contactPerson: json['contact_person'] as String,
    mobile: json['mobile'] as String,
    email: json['email'] as String,
    status: OrganizationStatus.fromJson(json['status'] as String),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
  );

  Map<String, dynamic> _toJson(Organization value) => {
    'name': value.name.trim(),
    'registration_number': value.registrationNumber.trim(),
    'registration_date': value.registrationDate
        .toIso8601String()
        .split('T')
        .first,
    'address': value.address.trim(),
    'city': value.city.trim(),
    'district': value.district.trim(),
    'state': value.state.trim(),
    'pincode': value.pincode.trim(),
    'contact_person': value.contactPerson.trim(),
    'mobile': value.mobile.trim(),
    'email': value.email.trim().toLowerCase(),
    'status': value.status.name,
  };

  String _messageFor(PostgrestException error) {
    if (error.code == '42501') {
      return 'You do not have permission to manage Patsansthas.';
    }
    return 'The Patsanstha request could not be completed.';
  }
}
