import 'package:firstpay/features/enach_mandates/domain/enach_mandate.dart';
import 'package:firstpay/features/enach_mandates/domain/enach_mandate_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEnachMandateRepository implements EnachMandateRepository {
  const SupabaseEnachMandateRepository(this.client);
  final SupabaseClient client;
  @override
  Future<List<EnachMandate>> getMandates() async {
    try {
      final rows = await client
          .from('enach_mandates')
          .select()
          .order('created_at', ascending: false);
      return rows.map(_from).toList(growable: false);
    } on Object {
      throw const EnachMandateFailure('Unable to load e-NACH mandates.');
    }
  }

  @override
  Future<EnachMandate> getMandate(String id) async {
    try {
      return _from(
        await client.from('enach_mandates').select().eq('id', id).single(),
      );
    } on Object {
      throw const EnachMandateFailure('Unable to load this e-NACH mandate.');
    }
  }

  @override
  Future<EnachMandate> createDraft(EnachMandate v) async {
    try {
      return _from(
        await client.from('enach_mandates').insert(_json(v)).select().single(),
      );
    } on Object {
      throw const EnachMandateFailure('Unable to create this e-NACH draft.');
    }
  }

  @override
  Future<EnachMandate> updateDraft(EnachMandate v) async {
    try {
      return _from(
        await client
            .from('enach_mandates')
            .update(_json(v))
            .eq('id', v.id)
            .eq('status', 'draft')
            .select()
            .single(),
      );
    } on Object {
      throw const EnachMandateFailure(
        'Only draft e-NACH mandates can be edited.',
      );
    }
  }

  @override
  Future<void> cancelDraft(String id) async {
    try {
      await client
          .from('enach_mandates')
          .update({'status': 'cancelled'})
          .eq('id', id)
          .eq('status', 'draft');
    } on Object {
      throw const EnachMandateFailure(
        'Only draft e-NACH mandates can be cancelled.',
      );
    }
  }

  EnachMandate _from(Map<String, dynamic> j) => EnachMandate(
    id: j['id'] as String,
    referenceNumber: j['mandate_reference_number'] as String,
    organizationId: j['organization_id'] as String,
    customerId: j['customer_id'] as String,
    accountHolderName: j['account_holder_name'] as String,
    bankName: j['bank_name'] as String,
    branchName: j['branch_name'] as String,
    accountNumber: j['account_number'] as String,
    ifscCode: j['ifsc_code'] as String,
    accountType: j['account_type'] as String,
    maximumDebitAmount: (j['maximum_debit_amount'] as num).toDouble(),
    frequency: EnachFrequency.values.byName(j['debit_frequency'] as String),
    startDate: DateTime.parse(j['start_date'] as String),
    endDate: DateTime.parse(j['end_date'] as String),
    purpose: j['purpose'] as String,
    sponsorBank: j['sponsor_bank'] as String,
    destinationBank: j['destination_bank'] as String,
    authenticationMode: EnachAuthenticationMode.values.byName(
      j['authentication_mode'] as String,
    ),
    status: EnachStatus.values.byName(j['status'] as String),
    remarks: j['remarks'] as String?,
    createdAt: DateTime.tryParse(j['created_at'] as String? ?? ''),
    updatedAt: DateTime.tryParse(j['updated_at'] as String? ?? ''),
  );
  Map<String, dynamic> _json(EnachMandate v) => {
    'organization_id': v.organizationId,
    'customer_id': v.customerId,
    'account_holder_name': v.accountHolderName.trim(),
    'bank_name': v.bankName.trim(),
    'branch_name': v.branchName.trim(),
    'account_number': v.accountNumber.trim(),
    'ifsc_code': v.ifscCode.trim().toUpperCase(),
    'account_type': v.accountType,
    'maximum_debit_amount': v.maximumDebitAmount,
    'debit_frequency': v.frequency.name,
    'start_date': v.startDate.toIso8601String().split('T').first,
    'end_date': v.endDate.toIso8601String().split('T').first,
    'purpose': v.purpose.trim(),
    'sponsor_bank': v.sponsorBank.trim(),
    'destination_bank': v.destinationBank.trim(),
    'authentication_mode': v.authenticationMode.name,
    'status': 'draft',
    'remarks': v.remarks?.trim().isEmpty == true ? null : v.remarks?.trim(),
  };
}
