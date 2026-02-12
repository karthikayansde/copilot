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
      return AppStrings.newPasswordEMTValidator;
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
    }
    return null;
  }
}