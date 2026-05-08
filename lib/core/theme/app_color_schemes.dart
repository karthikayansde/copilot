import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_strings.dart';
import 'app_colors.dart';

class AppThemeModel {
  final String key;
  final String name;
  final ThemeData data;
  final ThemeMode mode;

  AppThemeModel({
    required this.key,
    required this.name,
    required this.data,
    required this.mode,
  });
}

class AppColorSchemes {
  final TextTheme _textTheme;

  AppColorSchemes(this._textTheme);

  ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surfaceTint: Colors.transparent,
    ),
    extensions: extensionColors,
    textTheme: GoogleFonts.interTextTheme(_textTheme),
  );

  ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surfaceTint: Colors.transparent,
    ),
    extensions: extensionColors,
    textTheme: GoogleFonts.interTextTheme(_textTheme),
  );

  static const String defaultThemeKey = "system";

  List<AppThemeModel> get options => [
    AppThemeModel(
      key: "system",
      name: AppStrings.themeSystem,
      mode: ThemeMode.system,
      data: light, // Default to light if system is requested but context not available
    ),
    AppThemeModel(
      key: "light",
      name: AppStrings.themeLight,
      mode: ThemeMode.light,
      data: light,
    ),
    AppThemeModel(
      key: "dark",
      name: AppStrings.themeDark,
      mode: ThemeMode.dark,
      data: dark,
    ),
  ];
}

List<AppColorsExtension> extensionColors = [
  const AppColorsExtension(
    success: AppColors.successGreen,
    warning: AppColors.warning,
    info: AppColors.infoBlue,
  ),
];

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color success;
  final Color warning;
  final Color info;

  const AppColorsExtension({
    required this.success,
    required this.warning,
    required this.info,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({Color? success, Color? warning, Color? info}) {
    return AppColorsExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}


// static ThemeData get lightTheme {
//   final ColorScheme colorScheme = ColorScheme.fromSeed(
//     seedColor: Colors.deepPurple,
//
//     brightness: Brightness.light,
//
//     // primary: Colors.red,
//     // onPrimary: Colors.red,
//     // primaryContainer: Colors.red,
//     // onPrimaryContainer: Colors.red,
//     //
//     // primaryFixed: Colors.red,
//     // onPrimaryFixed: Colors.red,
//     // primaryFixedDim: Colors.red,
//     // onPrimaryFixedVariant: Colors.red,
//     //
//     // secondary: Colors.red,
//     // onSecondary: Colors.red,
//     // secondaryContainer: Colors.red,
//     // onSecondaryContainer: Colors.red,
//     //
//     // secondaryFixed: Colors.red,
//     // onSecondaryFixed: Colors.red,
//     // secondaryFixedDim: Colors.red,
//     // onSecondaryFixedVariant: Colors.red,
//     //
//     // tertiary: Colors.red,
//     // onTertiary: Colors.red,
//     // tertiaryContainer: Colors.red,
//     // onTertiaryContainer: Colors.red,
//     //
//     // tertiaryFixed: Colors.red,
//     // onTertiaryFixed: Colors.red,
//     // tertiaryFixedDim: Colors.red,
//     // onTertiaryFixedVariant: Colors.red,
//     //
//     // error: Colors.red,
//     // onError: Colors.red,
//     // errorContainer: Colors.red,
//     // onErrorContainer: Colors.red,
//     //
//     // surfaceDim: Colors.red,
//     // surface: Colors.red,
//     // surfaceBright: Colors.red,
//     // surfaceContainerLowest: Colors.red,
//     // surfaceContainerLow: Colors.red,
//     // surfaceContainer: Colors.red,
//     // surfaceContainerHigh: Colors.red,
//     // surfaceContainerHighest: Colors.red,
//     // onSurface: Colors.red,
//     // onSurfaceVariant: Colors.red,
//     // surfaceTint: Colors.red,
//     //
//     // outline: Colors.red,
//     // shadow: Colors.red,
//     // inverseSurface: Colors.red,
//     // onInverseSurface: Colors.red,
//     // inversePrimary: Colors.red,
//   );
//
//   return ThemeData(
//       useMaterial3: true,
//       colorScheme: colorScheme,
//       fontFamily: _fontFamily
//   );
// }


/// theme visual
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("data"),),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AppTheme.instance.dropdownBuilder(
//                   (selectedKey, themeMap, changeTheme) {
//                 return DropdownButton<String>(
//                   value: selectedKey,
//                   onChanged: (key) {
//                     changeTheme(key!);
//                     AppTheme.instance.updateTheme(key);
//                   },
//                   items: themeMap.entries
//                       .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value.name)))
//                       .toList(),
//                 );
//               },
//             ),
//             _ColorSchemeSection(),
//             SizedBox(height: 32),
//             _ButtonsSection(),
//             SizedBox(height: 32),
//             _InputsSection(),
//             SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // =================================
// // COLOR SCHEME SECTION
// // =================================
// class _ColorSchemeSection extends StatelessWidget {
//   const _ColorSchemeSection();
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Color Scheme', style: theme.textTheme.headlineMedium),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: [
//             _ColorCard('primary', colorScheme.primary, colorScheme.onPrimary),
//             _ColorCard('secondary', colorScheme.secondary, colorScheme.onSecondary),
//             _ColorCard('tertiary', colorScheme.tertiary, colorScheme.onTertiary),
//             _ColorCard('surface', colorScheme.surface, colorScheme.onSurface),
//             _ColorCard('background', colorScheme.surface, colorScheme.onSurface),
//             _ColorCard('error', colorScheme.error, colorScheme.onError),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _ColorCard extends StatelessWidget {
//   final String name;
//   final Color color;
//   final Color onColor;
//
//   const _ColorCard(this.name, this.color, this.onColor);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Text(
//           name,
//           style: Theme.of(context).textTheme.labelMedium?.copyWith(
//             color: onColor,
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// // =================================
// // BUTTONS SECTION
// // =================================
// class _ButtonsSection extends StatelessWidget {
//   const _ButtonsSection();
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Buttons', style: theme.textTheme.headlineMedium),
//         const SizedBox(height: 16),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               children: [
//                 ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
//                 FilledButton(onPressed: () {}, child: const Text('Filled')),
//                 OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
//                 TextButton(onPressed: () {}, child: const Text('Text')),
//                 ElevatedButton(onPressed: null, child: const Text('Disabled')),
//                 FilledButton.icon(
//                   onPressed: () {},
//                   icon: const Icon(Icons.add),
//                   label: const Text('With Icon'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // =================================
// // INPUTS SECTION
// // =================================
// class _InputsSection extends StatelessWidget {
//   const _InputsSection();
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Text Inputs', style: theme.textTheme.headlineMedium),
//         const SizedBox(height: 16),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 TextField(
//                   decoration: const InputDecoration(
//                     labelText: 'TextField',
//                     hintText: 'Enter some text',
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   decoration: const InputDecoration(
//                     labelText: 'TextFormField with Error',
//                     hintText: 'This field has an error',
//                     prefixIcon: Icon(Icons.email),
//                     errorText: 'Invalid email address',
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const TextField(
//                   enabled: false,
//                   decoration: InputDecoration(
//                     labelText: 'Disabled TextField',
//                     hintText: 'This field is disabled',
//                     prefixIcon: Icon(Icons.lock),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

///check current all colors
//
// final scheme = Theme.of(context).colorScheme;
//
// // All main properties (2026 complete list)
// final colorMap = {
//   'primary': scheme.primary,
//   'onPrimary': scheme.onPrimary,
//   'primaryContainer': scheme.primaryContainer,
//   'onPrimaryContainer': scheme.onPrimaryContainer,
//   'secondary': scheme.secondary,
//   'onSecondary': scheme.onSecondary,
//   'secondaryContainer': scheme.secondaryContainer,
//   'onSecondaryContainer': scheme.onSecondaryContainer,
//   'tertiary': scheme.tertiary,
//   'onTertiary': scheme.onTertiary,
//   'tertiaryContainer': scheme.tertiaryContainer,
//   'onTertiaryContainer': scheme.onTertiaryContainer,
//   'error': scheme.error,
//   'onError': scheme.onError,
//   'errorContainer': scheme.errorContainer,
//   'onErrorContainer': scheme.onErrorContainer,
//   'surface': scheme.surface,
//   'onSurface': scheme.onSurface,
//   'surfaceDim': scheme.surfaceDim,
//   'surfaceBright': scheme.surfaceBright,
//   'surfaceContainerLowest': scheme.surfaceContainerLowest,
//   'surfaceContainerLow': scheme.surfaceContainerLow,
//   'surfaceContainer': scheme.surfaceContainer,
//   'surfaceContainerHigh': scheme.surfaceContainerHigh,
//   'surfaceContainerHighest': scheme.surfaceContainerHighest,
//   'onSurfaceVariant': scheme.onSurfaceVariant,
//   'outline': scheme.outline,
//   'outlineVariant': scheme.outlineVariant,
//   'shadow': scheme.shadow,
//   'scrim': scheme.scrim,
//   'inverseSurface': scheme.inverseSurface,
//   'onInverseSurface': scheme.onInverseSurface, // sometimes called inverseOnSurface
//   'inversePrimary': scheme.inversePrimary,
//   'surfaceTint': scheme.surfaceTint,
//   // Deprecated ones (still exist but avoid using):
//   // 'background': scheme.background,
//   // 'onBackground': scheme.onBackground,
//   // 'surfaceVariant': scheme.surfaceVariant,
// };

// Widget asdf(){
//   return
//     Expanded(
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: colorMap.entries.map((entry) {
//           final color = entry.value;
//           final textColor = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
//           return Card(
//             color: color,
//             child: ListTile(
//               title: Text(
//                 entry.key,
//                 style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(
//                 '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
//                 style: TextStyle(color: textColor.withOpacity(0.8)),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
// }


class AppTextTheme {
  AppTextTheme._();

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.15,
    ),
    displaySmall: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    headlineLarge: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.28,
    ),
    headlineSmall: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
    ),
    titleLarge: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      // fontFamily: AppAssets.fontBody,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      // fontFamily: AppAssets.fontBody,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      // fontFamily: AppAssets.fontBody,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.42,
    ),
    bodySmall: TextStyle(
      // fontFamily: AppAssets.fontBody,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
    labelLarge: TextStyle(
      // fontFamily: AppAssets.fontHead,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.42,
    ),
    labelMedium: TextStyle(
      // fontFamily: AppAssets.fontBody,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      // fontFamily: AppAssets.fontBody,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );
}