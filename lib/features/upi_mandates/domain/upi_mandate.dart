enum MandateFrequency { daily, weekly, monthly, quarterly, halfYearly, yearly }

enum MandateStatus { draft, pending, approved, rejected, cancelled }

extension MandateFrequencyLabel on MandateFrequency {
  String get label => switch (this) {
    MandateFrequency.daily => 'Daily',
    MandateFrequency.weekly => 'Weekly',
    MandateFrequency.monthly => 'Monthly',
    MandateFrequency.quarterly => 'Quarterly',
    MandateFrequency.halfYearly => 'Half-Yearly',
    MandateFrequency.yearly => 'Yearly',
  };
}

extension MandateStatusLabel on MandateStatus {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class UpiMandate {
  const UpiMandate({
    required this.id,
    required this.referenceNumber,
    required this.organizationId,
    required this.customerId,
    required this.bankAccount,
    required this.upiId,
    required this.mandateAmount,
    required this.maximumAmount,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.purpose,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });
  final String id,
      referenceNumber,
      organizationId,
      customerId,
      bankAccount,
      upiId,
      purpose;
  final double mandateAmount, maximumAmount;
  final MandateFrequency frequency;
  final DateTime startDate, endDate;
  final MandateStatus status;
  final DateTime? createdAt, updatedAt;
  UpiMandate copyWith({MandateStatus? status}) => UpiMandate(
    id: id,
    referenceNumber: referenceNumber,
    organizationId: organizationId,
    customerId: customerId,
    bankAccount: bankAccount,
    upiId: upiId,
    mandateAmount: mandateAmount,
    maximumAmount: maximumAmount,
    frequency: frequency,
    startDate: startDate,
    endDate: endDate,
    purpose: purpose,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
