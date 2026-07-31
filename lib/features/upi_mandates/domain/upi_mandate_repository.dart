import 'package:firstpay/features/upi_mandates/domain/upi_mandate.dart';

abstract interface class UpiMandateRepository {
  Future<List<UpiMandate>> getMandates();
  Future<UpiMandate> getMandate(String id);
  Future<UpiMandate> createDraft(UpiMandate value);
  Future<UpiMandate> updateDraft(UpiMandate value);
  Future<void> cancelDraft(String id);
}

class UpiMandateFailure implements Exception {
  const UpiMandateFailure(this.message);
  final String message;
}
