/// Reusable form validators shared across the auth forms.
class Validators {
  Validators._();

  static final RegExp _studentEmailRegExp = RegExp(
    r'^[A-Za-z]\.[^@\s]+@alustudent\.com$',
    caseSensitive: false,
  );
  static final RegExp _staffEmailRegExp = RegExp(
    r'^[^@\s]+@alueducation\.com$',
    caseSensitive: false,
  );

  /// ALU student email: one initial character, a dot, a string, then
  /// `@alustudent.com` (for example `a.muhawenim@alustudent.com`).
  static String? studentEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email is required';
    if (!_studentEmailRegExp.hasMatch(input)) {
      return 'Use your ALU student email (e.g. a.lastname@alustudent.com)';
    }
    return null;
  }

  /// ALU staff email: any local part followed by `@alueducation.com`.
  static String? staffEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email is required';
    if (!_staffEmailRegExp.hasMatch(input)) {
      return 'Use your ALU staff email (e.g. name@alueducation.com)';
    }
    return null;
  }

  /// Accepts either an ALU student or staff email.
  static String? aluEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email is required';
    if (_studentEmailRegExp.hasMatch(input) ||
        _staffEmailRegExp.hasMatch(input)) {
      return null;
    }
    return 'Use your ALU email (a.lastname@alustudent.com or name@alueducation.com)';
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Password is required';
    if (input.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final input = value ?? '';
    if (input.isEmpty) return 'Please confirm your password';
    if (input != original) return 'Passwords do not match';
    return null;
  }

  static String? name(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Name is required';
    if (input.length < 2) return 'Enter your full name';
    return null;
  }

  static String? required(String? value, String label) {
    if ((value ?? '').trim().isEmpty) return '$label is required';
    return null;
  }
}
