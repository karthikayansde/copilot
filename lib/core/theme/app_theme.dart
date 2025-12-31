import 'package:copilot/core/theme/styles.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        fontFamily: 'League Spartan',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: false,
          titleTextStyle: appBarTitleStyle,
          titleSpacing: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardThemeData(color: Colors.white),
        useMaterial3: true,
      );

  // static ThemeData get darkTheme => ThemeData(
  //   colorScheme: ColorScheme.fromSeed(
  //     seedColor: AppColors.primary,
  //     brightness: Brightness.dark,
  //   ),
  //   useMaterial3: true,
  // );
}
