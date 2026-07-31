enum EnachFrequency {
  daily,
  weekly,
  monthly,
  quarterly,
  halfYearly,
  yearly,
  asPresented,
}

enum EnachAuthenticationMode { netBanking, debitCard, physical }

enum EnachStatus { draft, pending, approved, rejected, cancelled }

extension EnachFrequencyLabel on EnachFrequency {
  String get label => switch (this) {
    EnachFrequency.daily => 'Daily',
    EnachFrequency.weekly => 'Weekly',
    EnachFrequency.monthly => 'Monthly',
    EnachFrequency.quarterly => 'Quarterly',
    EnachFrequency.halfYearly => 'Half-Yearly',
    EnachFrequency.yearly => 'Yearly',
    EnachFrequency.asPresented => 'As Presented',
  };
}

extension EnachAuthenticationModeLabel on EnachAuthenticationMode {
  String get label => switch (this) {
    EnachAuthenticationMode.netBanking => 'Net Banking',
    EnachAuthenticationMode.debitCard => 'Debit Card',
    EnachAuthenticationMode.physical => 'Physical',
  };
}

extension EnachStatusLabel on EnachStatus {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class EnachMandate {
  const EnachMandate({
    required this.id,
    required this.referenceNumber,
    required this.organizationId,
    required this.customerId,
    required this.accountHolderName,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountType,
    required this.maximumDebitAmount,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.purpose,
    required this.sponsorBank,
    required this.destinationBank,
    required this.authenticationMode,
    required this.status,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });
  final String id,
      referenceNumber,
      organizationId,
      customerId,
      accountHolderName,
      bankName,
      branchName,
      accountNumber,
      ifscCode,
      accountType,
      purpose,
      sponsorBank,
      destinationBank;
  final double maximumDebitAmount;
  final EnachFrequency frequency;
  final DateTime startDate, endDate;
  final EnachAuthenticationMode authenticationMode;
  final EnachStatus status;
  final String? remarks;
  final DateTime? createdAt, updatedAt;
  EnachMandate copyWith({EnachStatus? status}) => EnachMandate(
    id: id,
    referenceNumber: referenceNumber,
    organizationId: organizationId,
    customerId: customerId,
    accountHolderName: accountHolderName,
    bankName: bankName,
    branchName: branchName,
    accountNumber: accountNumber,
    ifscCode: ifscCode,
    accountType: accountType,
    maximumDebitAmount: maximumDebitAmount,
    frequency: frequency,
    startDate: startDate,
    endDate: endDate,
    purpose: purpose,
    sponsorBank: sponsorBank,
    destinationBank: destinationBank,
    authenticationMode: authenticationMode,
    status: status ?? this.status,
    remarks: remarks,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
