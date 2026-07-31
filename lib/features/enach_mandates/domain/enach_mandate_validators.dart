abstract final class EnachMandateValidators {
  static String? required(String? v, String label) =>
      v == null || v.trim().isEmpty ? '$label is required' : null;
  static String? amount(String? v) {
    final r = required(v, 'Maximum Debit Amount');
    if (r != null) return r;
    final n = double.tryParse(v!.trim());
    return n != null && n > 0
        ? null
        : 'Maximum Debit Amount must be greater than zero';
  }

  static String? ifsc(String? v) {
    final r = required(v, 'IFSC Code');
    if (r != null) return r;
    return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v!.trim().toUpperCase())
        ? null
        : 'Enter a valid IFSC code';
  }

  static String? account(String? v) {
    final r = required(v, 'Account Number');
    if (r != null) return r;
    return RegExp(r'^\d{9,18}$').hasMatch(v!.trim())
        ? null
        : 'Account number must contain 9 to 18 digits';
  }

  static String? dates(DateTime? start, DateTime? end) {
    if (start == null) return 'Start Date is required';
    if (end == null) return 'End Date is required';
    return !end.isAfter(start) ? 'End Date must be after Start Date' : null;
  }
}
