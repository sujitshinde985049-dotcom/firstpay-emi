import 'package:firstpay/features/upi_mandates/domain/upi_mandate_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates positive amounts', () {
    expect(UpiMandateValidators.amount('100', 'Amount'), isNull);
    expect(UpiMandateValidators.amount('0', 'Amount'), isNotNull);
    expect(UpiMandateValidators.amount('-1', 'Amount'), isNotNull);
  });
  test('validates UPI IDs', () {
    expect(UpiMandateValidators.upiId('user@bank'), isNull);
    expect(UpiMandateValidators.upiId('invalid'), isNotNull);
  });
  test('validates date range', () {
    final start = DateTime(2026, 8, 1);
    expect(UpiMandateValidators.dates(start, DateTime(2026, 8, 1)), isNull);
    expect(UpiMandateValidators.dates(start, DateTime(2026, 7, 31)), isNotNull);
  });
}
