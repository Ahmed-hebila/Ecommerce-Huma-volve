/// Form field validators shared by the auth screens.
class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _lettersAndNumbers = RegExp(r'^[a-zA-Z0-9]+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Used on sign up: the API only accepts letters and numbers.
  static String? newPassword(String? value) {
    final error = password(value);
    if (error != null) return error;
    if (!_lettersAndNumbers.hasMatch(value!)) {
      return 'Password can only contain letters and numbers';
    }
    return null;
  }
}
