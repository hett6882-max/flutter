class Validators {
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String field = 'This field'}) {
    if (value == null || value.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String field = 'This field'}) {
    if (value != null && value.trim().length > max) {
      return '$field must be at most $max characters';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    final v = value.trim();
    if (v.length < 3) return 'Username must be at least 3 characters';
    if (v.length > 20) return 'Username must be at most 20 characters';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
      return 'Username can only contain letters, numbers and underscore';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }
}
