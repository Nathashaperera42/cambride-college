class Validators {
  static String? name(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Name is required';
    if (s.length < 2) return 'Name must be at least 2 characters';
    if (s.length > 60) return 'Name must be under 60 characters';
    return null;
  }

  static String? email(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value);
    return ok ? null : 'Enter a valid email address';
  }

  static const passwordMaxLength = 64;

  static String? password(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'Password must be at least 8 characters';
    if (s.length > passwordMaxLength) {
      return 'Password must be under $passwordMaxLength characters';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(s)) {
      return 'Password must include at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(s)) {
      return 'Password must include at least one number';
    }
    return null;
  }

  static String? confirm(String? v, String original) =>
      (v != original) ? 'Passwords do not match' : null;

  /// Optional phone — returns null if empty (field not required by default).
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final digits = v.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Generic required field with optional max-length check.
  static String? required(String? v, {String label = 'This field', int? maxLength}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return '$label is required';
    if (maxLength != null && s.length > maxLength) {
      return '$label must be under $maxLength characters';
    }
    return null;
  }
}
