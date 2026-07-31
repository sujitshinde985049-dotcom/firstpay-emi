import 'package:firstpay/features/organizations/domain/organization.dart';

abstract interface class OrganizationRepository {
  Future<List<Organization>> getOrganizations();
  Future<Organization> getOrganization(String id);
  Future<Organization> createOrganization(Organization organization);
  Future<Organization> updateOrganization(Organization organization);
  Future<void> updateStatus(String id, OrganizationStatus status);
  Future<bool> registrationNumberExists(
    String registrationNumber, {
    String? excludeId,
  });
}

class OrganizationFailure implements Exception {
  const OrganizationFailure(this.message);
  final String message;
}

class DuplicateRegistrationNumberFailure extends OrganizationFailure {
  const DuplicateRegistrationNumberFailure()
    : super('A Patsanstha with this registration number already exists.');
}
