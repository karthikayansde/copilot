import 'app_strings.dart';

class AppValidators {

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.nameValidator;  
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailEMTValidator;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailValidator;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordEMTValidator;
    } else if (value.length < 8 || value.length > 100) {
      return AppStrings.passwordValidator;
    }
    return null;
  }
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordEMTValidator;
    } else if (value.length < 8 || value.length > 100) {
      return AppStrings.passwordValidator;
    }
    return null;
  }
  static String? confirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordEMTValidator;
    } else if (value.length < 8 || value.length > 100) {
      return AppStrings.confirmPasswordValidator;
    }
    return null;
  }

  static String? organizationName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.organizationNameValidator;
    }
    return null;
  }
}