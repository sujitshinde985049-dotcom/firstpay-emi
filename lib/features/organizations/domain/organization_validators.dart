abstract final class OrganizationValidators {
  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    final requiredMessage = required(value, 'Email');
    if (requiredMessage != null) return requiredMessage;
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim());
    return valid ? null : 'Enter a valid email address';
  }

  static String? mobile(String? value) {
    final requiredMessage = required(value, 'Mobile');
    if (requiredMessage != null) return requiredMessage;
    return RegExp(r'^[6-9]\d{9}$').hasMatch(value!.trim())
        ? null
        : 'Enter a valid 10-digit mobile number';
  }

  static String? pincode(String? value) {
    final requiredMessage = required(value, 'PIN Code');
    if (requiredMessage != null) return requiredMessage;
    return RegExp(r'^\d{6}$').hasMatch(value!.trim())
        ? null
        : 'Enter a valid 6-digit PIN code';
  }
}
