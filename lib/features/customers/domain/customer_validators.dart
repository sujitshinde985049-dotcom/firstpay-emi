abstract final class CustomerValidators {
  static String? required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required' : null;
  static String? mobile(String? value) {
    final r = required(value, 'Mobile Number');
    if (r != null) return r;
    return RegExp(r'^[6-9]\d{9}$').hasMatch(value!.trim())
        ? null
        : 'Enter a valid 10-digit mobile number';
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
        ? null
        : 'Enter a valid email address';
  }

  static String? pincode(String? value) {
    final r = required(value, 'PIN Code');
    if (r != null) return r;
    return RegExp(r'^\d{6}$').hasMatch(value!.trim())
        ? null
        : 'Enter a valid 6-digit PIN code';
  }

  static String? ifsc(String? value) {
    final r = required(value, 'IFSC Code');
    if (r != null) return r;
    return RegExp(
          r'^[A-Z]{4}0[A-Z0-9]{6}$',
        ).hasMatch(value!.trim().toUpperCase())
        ? null
        : 'Enter a valid IFSC code';
  }

  static String? accountNumber(String? value) {
    final r = required(value, 'Account Number');
    if (r != null) return r;
    return RegExp(r'^\d{9,18}$').hasMatch(value!.trim())
        ? null
        : 'Account number must contain 9 to 18 digits';
  }

  static String? aadhaar(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return RegExp(r'^\d{12}$').hasMatch(value.trim())
        ? null
        : 'Aadhaar number must contain 12 digits';
  }

  static String? pan(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return RegExp(
          r'^[A-Z]{5}[0-9]{4}[A-Z]$',
        ).hasMatch(value.trim().toUpperCase())
        ? null
        : 'Enter a valid PAN number';
  }
}
