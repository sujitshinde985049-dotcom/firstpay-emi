abstract final class UpiMandateValidators {
  static String? required(String? v, String label) =>
      v == null || v.trim().isEmpty ? '$label is required' : null;
  static String? upiId(String? v) {
    final r = required(v, 'UPI ID');
    if (r != null) return r;
    return RegExp(
          r'^[A-Za-z0-9._-]{2,256}@[A-Za-z][A-Za-z0-9.-]{1,63}$',
        ).hasMatch(v!.trim())
        ? null
        : 'Enter a valid UPI ID';
  }

  static String? amount(String? v, String label) {
    final r = required(v, label);
    if (r != null) return r;
    final n = double.tryParse(v!.trim());
    return n != null && n > 0 ? null : '$label must be greater than zero';
  }

  static String? dates(DateTime? start, DateTime? end) {
    if (start == null) return 'Start Date is required';
    if (end == null) return 'End Date is required';
    return end.isBefore(start)
        ? 'End Date must be on or after Start Date'
        : null;
  }
}
