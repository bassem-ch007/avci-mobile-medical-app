class Validators {
  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!regex.hasMatch(value.trim())) {
      return 'Invalid email';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 4) {
      return 'Password must contain at least 4 characters';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final regex = RegExp(r'^[0-9+\s]{6,20}$');

    if (!regex.hasMatch(value.trim())) {
      return 'Invalid phone number';
    }

    return null;
  }

  static String? score(String? value, String label, int min, int max) {
    if (value == null || value.trim().isEmpty) return null;

    final number = int.tryParse(value.trim());

    if (number == null) {
      return '$label must be a number';
    }

    if (number < min || number > max) {
      return '$label must be between $min and $max';
    }

    return null;
  }

  static String? positiveNumber(String? value, String label) {
    if (value == null || value.trim().isEmpty) return null;

    final number = double.tryParse(value.trim());

    if (number == null) {
      return '$label must be a number';
    }

    if (number <= 0) {
      return '$label must be positive';
    }

    return null;
  }
}
