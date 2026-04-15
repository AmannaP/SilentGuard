class Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Must be exactly 10 digits and start with 0
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Phone number must be exactly 10 digits starting with 0';
    }
    return null;
  }

  static String? name(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    // No numbers allowed
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return '$fieldName cannot contain numbers';
    }
    return null;
  }
}
