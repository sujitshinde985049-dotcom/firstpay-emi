import 'package:firstpay/features/customers/application/customer_controller.dart';
import 'package:firstpay/features/customers/domain/customer.dart';
import 'package:firstpay/features/customers/domain/customer_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements CustomerRepository {
  FakeRepo(this.items);
  final List<Customer> items;
  bool duplicate = false;
  CustomerStatus? changed;
  @override
  Future<Customer> createCustomer(Customer v) async {
    items.add(v);
    return v;
  }

  @override
  Future<List<Customer>> getCustomers() async => List.of(items);
  @override
  Future<Customer> getCustomer(String id) async =>
      items.singleWhere((x) => x.id == id);
  @override
  Future<bool> mobileExists(String o, String m, {String? excludeId}) async =>
      duplicate;
  @override
  Future<Customer> updateCustomer(Customer v) async => v;
  @override
  Future<void> updateStatus(String id, CustomerStatus s) async {
    changed = s;
  }
}

Customer customer({
  String id = '1',
  String name = 'Asha Patil',
  String mobile = '9876543210',
  CustomerStatus status = CustomerStatus.active,
}) => Customer(
  id: id,
  organizationId: 'org-1',
  fullName: name,
  mobile: mobile,
  dateOfBirth: DateTime(1990),
  gender: CustomerGender.female,
  address: 'Road',
  city: 'Pune',
  district: 'Pune',
  state: 'Maharashtra',
  pincode: '411001',
  accountHolderName: name,
  bankName: 'Bank',
  branchName: 'Main',
  accountNumber: '123456789',
  ifscCode: 'HDFC0001234',
  accountType: BankAccountType.savings,
  status: status,
);
void main() {
  test('searches supported fields and filters status', () async {
    final c = CustomerController(
      FakeRepo([
        customer(),
        customer(
          id: '2',
          name: 'Inactive User',
          mobile: '9123456789',
          status: CustomerStatus.inactive,
        ),
      ]),
    );
    await c.load();
    c.setSearchQuery('inactive');
    c.setStatusFilter(CustomerStatus.inactive);
    expect(c.state.filteredCustomers.single.id, '2');
  });
  test('prevents duplicate mobile within organization', () async {
    final r = FakeRepo([])..duplicate = true;
    final c = CustomerController(r);
    expect(
      await c.save(customer(), isNew: true),
      contains('selected Patsanstha'),
    );
    expect(r.items, isEmpty);
  });
  test('toggles active customer to inactive', () async {
    final v = customer();
    final r = FakeRepo([v]);
    final c = CustomerController(r);
    await c.load();
    expect(await c.toggleStatus(v), isTrue);
    expect(r.changed, CustomerStatus.inactive);
    expect(c.state.customers.single.status, CustomerStatus.inactive);
  });
}
