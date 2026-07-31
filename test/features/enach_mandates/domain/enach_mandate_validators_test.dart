import 'package:firstpay/features/enach_mandates/domain/enach_mandate_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates amount', () {
    expect(EnachMandateValidators.amount('1000'), isNull);
    expect(EnachMandateValidators.amount('0'), isNotNull);
  });
  test('validates IFSC and account number', () {
    expect(EnachMandateValidators.ifsc('HDFC0001234'), isNull);
    expect(EnachMandateValidators.ifsc('BAD'), isNotNull);
    expect(EnachMandateValidators.account('123456789'), isNull);
    expect(EnachMandateValidators.account('12'), isNotNull);
  });
  test('requires end date after start', () {
    final s = DateTime(2026, 8, 1);
    expect(EnachMandateValidators.dates(s, DateTime(2026, 8, 2)), isNull);
    expect(EnachMandateValidators.dates(s, s), isNotNull);
  });
}
