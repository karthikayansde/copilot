import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iMirAI/services/local_storage_service/local_storage_service.dart';
import 'package:iMirAI/utils/app_strings.dart';
import 'package:iMirAI/views/home_screen.dart';
import 'package:iMirAI/widgets/button_widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'controller/home_controller.dart';
import 'core/theme/app_color_schemes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/styles.dart';
import 'services/shared_pref_manager.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  ILocalStorage? localStorage;
  localStorage = LocalStorageService();
  await localStorage.init();
  AppTheme(isNative: true, colorSchemes: AppColorSchemes(AppTextTheme.textTheme).options, storage: localStorage);

  runApp(const MyApp());
}

// 1. Create this class to bypass SSL checks
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme.instance.themeWrapper(
      (theme, darkTheme, themeMode) => GetMaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        home: const AuthScreen(),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final isLoggedIn =
        await SharedPrefManager.instance.getBoolAsync(SharedPrefManager.isLoggedIn) ?? false;
    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } else {
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
      await _checkBiometrics();
      if (_canCheckBiometrics) {
        _authenticate();
      }
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (mounted) {
        setState(() {
          _canCheckBiometrics = canCheckBiometrics || isDeviceSupported;
        });
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
      if (mounted) {
        setState(() {
          _canCheckBiometrics = false;
        });
      }
    }
  }

  Future<void> _authenticate() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Welcome Back',
            cancelButton: 'Cancel',
            signInHint: 'Verify your identity',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
        biometricOnly: false,
      );

      if (authenticated && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('Authentication error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Authentication',
              style: text28Bold.copyWith(
                fontSize: 24,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 40),
            Icon(
              Icons.fingerprint,
              size: 100,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 40),
            if (_canCheckBiometrics)
              BasicButtonWidget(
                width: 250,
                onPressed: _authenticate,
                label: 'Unlock with Biometrics',
              )
            else
              Text(
                'Biometrics not available.\nPlease log in again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.error),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await SharedPrefManager.instance.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                }
              },
              child: Text(
                'Log out',
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}