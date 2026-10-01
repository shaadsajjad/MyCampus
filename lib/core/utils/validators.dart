import 'package:easy_localization/easy_localization.dart';

/// Shared client-side form validators, returning a localized error message
/// (or `null` when the value is valid) for use as a `TextFormField.validator`.
class Validators {
  new _();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phonePattern = RegExp(r'^\+?[0-9\s-]{7,15}$');

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'validation.invalidEmail'.tr();
    }
    return null;
  }

  static String? phone(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (!_phonePattern.hasMatch(value!.trim())) {
      return 'validation.invalidPhone'.tr();
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (value!.length < 8) {
      return 'validation.passwordTooShort'.tr();
    }
    return null;
  }

  /// Validates a confirmation field against [password].
  static String? Function(String?) confirmPassword(String Function() password) {
    return (value) {
      final requiredError = required(value);
      if (requiredError != null) return requiredError;
      if (value != password()) {
        return 'validation.passwordMismatch'.tr();
      }
      return null;
    };
  }
}
