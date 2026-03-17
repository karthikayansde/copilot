import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';

class LoadingWidget {
  static void showLoader(BuildContext context) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: loader(),
      ),
      barrierDismissible: false,
    );
  }

  static Widget loader() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  static void closeLoader(BuildContext context) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
