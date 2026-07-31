import 'package:firstpay/features/customers/domain/customer.dart';

abstract interface class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<Customer> getCustomer(String id);
  Future<Customer> createCustomer(Customer value);
  Future<Customer> updateCustomer(Customer value);
  Future<void> updateStatus(String id, CustomerStatus status);
  Future<bool> mobileExists(
    String organizationId,
    String mobile, {
    String? excludeId,
  });
}

class CustomerFailure implements Exception {
  const CustomerFailure(this.message);
  final String message;
}

class DuplicateCustomerMobileFailure extends CustomerFailure {
  const DuplicateCustomerMobileFailure()
    : super(
        'A customer with this mobile number already exists in the selected Patsanstha.',
      );
}
