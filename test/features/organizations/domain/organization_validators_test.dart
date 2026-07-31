import 'package:firstpay/features/organizations/domain/organization_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates required organization fields', () {
    expect(OrganizationValidators.required('', 'Name'), 'Name is required');
    expect(OrganizationValidators.required('First Society', 'Name'), isNull);
  });

  test('validates email addresses', () {
    expect(OrganizationValidators.email('invalid'), isNotNull);
    expect(OrganizationValidators.email('admin@example.com'), isNull);
  });

  test('validates Indian mobile and PIN formats', () {
    expect(OrganizationValidators.mobile('5123456789'), isNotNull);
    expect(OrganizationValidators.mobile('9876543210'), isNull);
    expect(OrganizationValidators.pincode('12345'), isNotNull);
    expect(OrganizationValidators.pincode('411001'), isNull);
  });
}
