import 'package:firstpay/features/upi_mandates/domain/upi_mandate.dart';
import 'package:firstpay/features/upi_mandates/domain/upi_mandate_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUpiMandateRepository implements UpiMandateRepository {
  const SupabaseUpiMandateRepository(this.client);
  final SupabaseClient client;
  @override
  Future<List<UpiMandate>> getMandates() async {
    try {
      final rows = await client
          .from('upi_mandates')
          .select()
          .order('created_at', ascending: false);
      return rows.map(_fromJson).toList(growable: false);
    } on PostgrestException catch (e) {
      throw UpiMandateFailure(_message(e));
    } on Object {
      throw const UpiMandateFailure('Unable to load UPI mandates.');
    }
  }

  @override
  Future<UpiMandate> getMandate(String id) async {
    try {
      return _fromJson(
        await client.from('upi_mandates').select().eq('id', id).single(),
      );
    } on Object {
      throw const UpiMandateFailure('Unable to load this mandate.');
    }
  }

  @override
  Future<UpiMandate> createDraft(UpiMandate v) async {
    try {
      return _fromJson(
        await client.from('upi_mandates').insert(_json(v)).select().single(),
      );
    } on PostgrestException catch (e) {
      throw UpiMandateFailure(_message(e));
    } on Object {
      throw const UpiMandateFailure('Unable to create this draft.');
    }
  }

  @override
  Future<UpiMandate> updateDraft(UpiMandate v) async {
    try {
      return _fromJson(
        await client
            .from('upi_mandates')
            .update(_json(v))
            .eq('id', v.id)
            .eq('status', 'draft')
            .select()
            .single(),
      );
    } on Object {
      throw const UpiMandateFailure('Only draft mandates can be edited.');
    }
  }

  @override
  Future<void> cancelDraft(String id) async {
    try {
      await client
          .from('upi_mandates')
          .update({'status': 'cancelled'})
          .eq('id', id)
          .eq('status', 'draft');
    } on Object {
      throw const UpiMandateFailure('Only draft mandates can be cancelled.');
    }
  }

  UpiMandate _fromJson(Map<String, dynamic> j) => UpiMandate(
    id: j['id'] as String,
    referenceNumber: j['reference_number'] as String,
    organizationId: j['organization_id'] as String,
    customerId: j['customer_id'] as String,
    bankAccount: j['bank_account'] as String,
    upiId: j['upi_id'] as String,
    mandateAmount: (j['mandate_amount'] as num).toDouble(),
    maximumAmount: (j['maximum_amount'] as num).toDouble(),
    frequency: MandateFrequency.values.byName(j['frequency'] as String),
    startDate: DateTime.parse(j['start_date'] as String),
    endDate: DateTime.parse(j['end_date'] as String),
    purpose: j['purpose'] as String,
    status: MandateStatus.values.byName(j['status'] as String),
    createdAt: DateTime.tryParse(j['created_at'] as String? ?? ''),
    updatedAt: DateTime.tryParse(j['updated_at'] as String? ?? ''),
  );
  Map<String, dynamic> _json(UpiMandate v) => {
    'organization_id': v.organizationId,
    'customer_id': v.customerId,
    'bank_account': v.bankAccount.trim(),
    'upi_id': v.upiId.trim(),
    'mandate_amount': v.mandateAmount,
    'maximum_amount': v.maximumAmount,
    'frequency': v.frequency.name,
    'start_date': v.startDate.toIso8601String().split('T').first,
    'end_date': v.endDate.toIso8601String().split('T').first,
    'purpose': v.purpose.trim(),
    'status': 'draft',
  };
  String _message(PostgrestException e) => e.code == '42501'
      ? 'You do not have permission to manage UPI mandates.'
      : 'The UPI mandate request could not be completed.';
}
