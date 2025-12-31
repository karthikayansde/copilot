import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../services/api/api_service.dart';
import '../utils/app_colors.dart';

class SnackBarWidget {

  static void show(
      BuildContext context, {
        required String message,
        required ContentType contentType,
        String title = '',
      }) {
    final snackBar = SnackBar(
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        color: contentType == ContentType.failure? AppColors.red: null,
      ),
      elevation: 0,
      backgroundColor: AppColors.transparent,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showError(BuildContext context) {
    show(
      context,
      title: apiErrorConfigDefault.title,
      message: apiErrorConfigDefault.message,
      contentType: apiErrorConfigDefault.contentType,
    );
  }
}