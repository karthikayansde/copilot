import 'package:flutter/material.dart';

import '../utils/app_images.dart';

class BackgroundImageWidget extends StatelessWidget {
  Widget child;
  BackgroundImageWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background image
        SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Image.asset(AppImages.bg, fit: BoxFit.cover),
        ),
        child,
      ],
    );
  }
}
