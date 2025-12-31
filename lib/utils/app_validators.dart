import 'app_strings.dart';

class AppValidators {

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.nameValidator;
    }
    return null;
  }
  static String? feedback(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.feedbackValidator;
    }
    return null;
  }
  static String? unit(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.uomValidator;
    }
    return null;
  }

  static String? mateCode(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.codeValidator;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.newPasswordEMTValidator;
    } else if (value.length < 6) {
      return AppStrings.passwordValidator;
    }
    return null;
  }
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordEMTValidator;
    } else if (value.length < 6) {
      return AppStrings.passwordValidator;
    }
    return null;
  }
  static String? confirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordEMTValidator;
    } else if (value.length < 6) {
      return AppStrings.confirmPasswordValidator;
    }
    return null;
  }
}