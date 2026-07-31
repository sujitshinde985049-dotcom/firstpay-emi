import 'package:firstpay/features/customers/domain/customer_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates mobile email and PIN', () {
    expect(CustomerValidators.mobile('9876543210'), isNull);
    expect(CustomerValidators.mobile('123'), isNotNull);
    expect(CustomerValidators.email(''), isNull);
    expect(CustomerValidators.email('bad'), isNotNull);
    expect(CustomerValidators.pincode('411001'), isNull);
  });
  test('validates mandate-ready bank fields', () {
    expect(CustomerValidators.ifsc('HDFC0001234'), isNull);
    expect(CustomerValidators.ifsc('BAD'), isNotNull);
    expect(CustomerValidators.accountNumber('123456789'), isNull);
    expect(CustomerValidators.accountNumber('123'), isNotNull);
  });
  test('validates optional identity fields', () {
    expect(CustomerValidators.aadhaar(''), isNull);
    expect(CustomerValidators.aadhaar('123456789012'), isNull);
    expect(CustomerValidators.pan('ABCDE1234F'), isNull);
    expect(CustomerValidators.pan('INVALID'), isNotNull);
  });
}
