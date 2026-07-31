enum OrganizationStatus {
  active('Active'),
  inactive('Inactive');

  const OrganizationStatus(this.label);
  final String label;

  static OrganizationStatus fromJson(String value) =>
      value.toLowerCase() == 'active' ? active : inactive;
}

class Organization {
  const Organization({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.registrationNumber,
    required this.registrationDate,
    required this.address,
    required this.city,
    required this.district,
    required this.state,
    required this.pincode,
    required this.contactPerson,
    required this.mobile,
    required this.email,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String name;
  final String registrationNumber;
  final DateTime registrationDate;
  final String address;
  final String city;
  final String district;
  final String state;
  final String pincode;
  final String contactPerson;
  final String mobile;
  final String email;
  final OrganizationStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Organization copyWith({OrganizationStatus? status}) => Organization(
    id: id,
    tenantId: tenantId,
    name: name,
    registrationNumber: registrationNumber,
    registrationDate: registrationDate,
    address: address,
    city: city,
    district: district,
    state: state,
    pincode: pincode,
    contactPerson: contactPerson,
    mobile: mobile,
    email: email,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
