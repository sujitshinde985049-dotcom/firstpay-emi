import 'package:firstpay/features/enach_mandates/domain/enach_mandate.dart';

abstract interface class EnachMandateRepository {
  Future<List<EnachMandate>> getMandates();
  Future<EnachMandate> getMandate(String id);
  Future<EnachMandate> createDraft(EnachMandate value);
  Future<EnachMandate> updateDraft(EnachMandate value);
  Future<void> cancelDraft(String id);
}

class EnachMandateFailure implements Exception {
  const EnachMandateFailure(this.message);
  final String message;
}
