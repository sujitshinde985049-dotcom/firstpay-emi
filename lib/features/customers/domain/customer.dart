enum CustomerStatus { active, inactive }

enum CustomerGender { male, female, other, preferNotToSay }

enum BankAccountType { savings, current }

extension CustomerStatusLabel on CustomerStatus {
  String get label => name[0].toUpperCase() + name.substring(1);
}

extension CustomerGenderLabel on CustomerGender {
  String get label => switch (this) {
    CustomerGender.male => 'Male',
    CustomerGender.female => 'Female',
    CustomerGender.other => 'Other',
    CustomerGender.preferNotToSay => 'Prefer not to say',
  };
}

extension BankAccountTypeLabel on BankAccountType {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class Customer {
  const Customer({
    required this.id,
    required this.organizationId,
    required this.fullName,
    required this.mobile,
    this.email,
    required this.dateOfBirth,
    required this.gender,
    this.aadhaarNumber,
    this.panNumber,
    required this.address,
    required this.city,
    required this.district,
    required this.state,
    required this.pincode,
    required this.accountHolderName,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountType,
    this.upiId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });
  final String id,
      organizationId,
      fullName,
      mobile,
      address,
      city,
      district,
      state,
      pincode,
      accountHolderName,
      bankName,
      branchName,
      accountNumber,
      ifscCode;
  final String? email, aadhaarNumber, panNumber, upiId;
  final DateTime dateOfBirth;
  final CustomerGender gender;
  final BankAccountType accountType;
  final CustomerStatus status;
  final DateTime? createdAt, updatedAt;
  Customer copyWith({CustomerStatus? status}) => Customer(
    id: id,
    organizationId: organizationId,
    fullName: fullName,
    mobile: mobile,
    email: email,
    dateOfBirth: dateOfBirth,
    gender: gender,
    aadhaarNumber: aadhaarNumber,
    panNumber: panNumber,
    address: address,
    city: city,
    district: district,
    state: state,
    pincode: pincode,
    accountHolderName: accountHolderName,
    bankName: bankName,
    branchName: branchName,
    accountNumber: accountNumber,
    ifscCode: ifscCode,
    accountType: accountType,
    upiId: upiId,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
