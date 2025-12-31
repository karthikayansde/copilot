import 'dart:math';

import 'package:copilot/core/theme/app_colors.dart';
import 'package:copilot/utils/app_strings.dart';
import 'package:copilot/widgets/button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import 'package:get/get.dart';
import 'controller/home_controller.dart';
import 'core/theme/styles.dart';
import 'services/shared_pref_manager.dart';
import 'views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
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
    // Add a small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 500));
    
    final isLoggedIn = await SharedPrefManager.instance.getBoolAsync(SharedPrefManager.isLoggedIn) ?? false;
    if (!mounted) return;

    if (!isLoggedIn) {
      // Not logged in -> Go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } else {
      // Logged in -> Setup Biometrics
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
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('Authentication error: $e');
      // Allow retry via button
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'Authentication',

              style: text28Bold.copyWith(fontSize: 24),
            ),
            SizedBox(height: 40,),
            Icon(
              Icons.fingerprint,
              size: 100,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 40),
            if (_canCheckBiometrics)
              BasicButtonWidget(
                width: 250,
                onPressed: _authenticate, 
                label: 'Unlock with Biometrics',
              )
            else
              const Text(
                'Biometrics not available.\nPlease log in again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                 await SharedPrefManager.instance.logout();
                 if(mounted){
                   Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                 }
              },
              child: Text('Log out',style: TextStyle(color: AppColors.textSecondary),),
            ),
          ],
        ),
      ),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Copilot'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => controller.logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SizedBox(),
              ),
        
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(() => TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search or speak...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                controller.isListening.value ? Icons.mic : Icons.mic_none,
                                color: controller.isListening.value ? Colors.red : Colors.deepPurple,
                                size: 28,
                              ),
                              onPressed: controller.speechEnabled.value
                                  ? (controller.isListening.value ? controller.stopListening : controller.startListening)
                                  : null,
                              tooltip: controller.isListening.value ? 'Stop listening' : 'Start voice search',
                            ),
                            if (controller.isListening.value)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        if (controller.hasText.value)
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.deepPurple),
                            onPressed: () async {
                              await controller.sendMessage(context);
                            },
                            tooltip: 'Send',
                          ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}