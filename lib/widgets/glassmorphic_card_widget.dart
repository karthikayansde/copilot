import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicCardWidget extends StatelessWidget {
  final Widget child;
  final double height;

  const GlassmorphicCardWidget({
    super.key,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Rounded corners
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: height,
        width: double.maxFinite,
        color: Colors.transparent, // To see the blur effect
        child: Stack(
          children: [
            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
              child: Container(),
            ),
            // Gradient & border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.white.withOpacity(0.8)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            // Card content
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
