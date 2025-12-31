import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class LoadingWidget {
  static void showLoader(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(canPop: false,
        child: loader());
      },
    );
  }

  static Widget loader() {
    return Center(child: SizedBox(height: 100, width: 100, child: Stack(
      alignment: Alignment.center,
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(right: 5.0),
        //   child: Image.asset('assets/images/loading.gif', height: 80),
        // ),
        SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            color: AppColors.white
          ),
        ),


      ],
    )));
  }

  static void closeLoader(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
