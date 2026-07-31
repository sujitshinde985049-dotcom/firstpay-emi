import 'package:firstpay/features/organizations/application/organization_controller.dart';
import 'package:firstpay/features/organizations/domain/organization.dart';
import 'package:firstpay/features/organizations/domain/organization_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements OrganizationRepository {
  _FakeRepository(this.items);
  final List<Organization> items;
  bool duplicate = false;
  OrganizationStatus? updatedStatus;

  @override
  Future<Organization> createOrganization(Organization organization) async {
    items.add(organization);
    return organization;
  }

  @override
  Future<List<Organization>> getOrganizations() async => List.of(items);

  @override
  Future<Organization> getOrganization(String id) async =>
      items.singleWhere((item) => item.id == id);

  @override
  Future<bool> registrationNumberExists(
    String registrationNumber, {
    String? excludeId,
  }) async => duplicate;

  @override
  Future<Organization> updateOrganization(Organization organization) async =>
      organization;

  @override
  Future<void> updateStatus(String id, OrganizationStatus status) async {
    updatedStatus = status;
  }
}

Organization _organization({
  String id = '1',
  String name = 'First Cooperative Society',
  String registrationNumber = 'REG-001',
  OrganizationStatus status = OrganizationStatus.active,
}) => Organization(
  id: id,
  tenantId: 'tenant-1',
  name: name,
  registrationNumber: registrationNumber,
  registrationDate: DateTime(2020),
  address: 'Main Road',
  city: 'Pune',
  district: 'Pune',
  state: 'Maharashtra',
  pincode: '411001',
  contactPerson: 'Admin User',
  mobile: '9876543210',
  email: 'admin@example.com',
  status: status,
);

void main() {
  test('search and status filters are combined', () async {
    final repository = _FakeRepository([
      _organization(),
      _organization(
        id: '2',
        name: 'Second Society',
        registrationNumber: 'REG-002',
        status: OrganizationStatus.inactive,
      ),
    ]);
    final controller = OrganizationController(repository);
    await controller.load();

    controller.setSearchQuery('second');
    controller.setStatusFilter(OrganizationStatus.inactive);

    expect(controller.state.filteredOrganizations, hasLength(1));
    expect(controller.state.filteredOrganizations.single.id, '2');
  });

  test('duplicate registration number prevents save', () async {
    final repository = _FakeRepository([])..duplicate = true;
    final controller = OrganizationController(repository);

    final error = await controller.save(_organization(), isNew: true);

    expect(error, contains('registration number already exists'));
    expect(repository.items, isEmpty);
  });

  test('toggle status updates local state after repository succeeds', () async {
    final organization = _organization();
    final repository = _FakeRepository([organization]);
    final controller = OrganizationController(repository);
    await controller.load();

    expect(await controller.toggleStatus(organization), isTrue);
    expect(repository.updatedStatus, OrganizationStatus.inactive);
    expect(
      controller.state.organizations.single.status,
      OrganizationStatus.inactive,
    );
  });
}
