// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:local_auth_android/local_auth_android.dart';
// import 'package:local_auth_ios/local_auth_ios.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Copilot',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const AuthScreen(),
//     );
//   }
// }
//
// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});
//
//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends State<AuthScreen> {
//   final LocalAuthentication auth = LocalAuthentication();
//   bool _canCheckBiometrics = false;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAuth();
//   }
//
//   Future<void> _initializeAuth() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     await _checkBiometrics();
//     await _checkIfLoggedIn();
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _checkIfLoggedIn() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//       if (isLoggedIn && mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error checking login status: $e');
//     }
//   }
//
//   Future<void> _checkBiometrics() async {
//     try {
//       final canCheckBiometrics = await auth.canCheckBiometrics;
//       final isDeviceSupported = await auth.isDeviceSupported();
//
//       if (mounted) {
//         setState(() {
//           _canCheckBiometrics = canCheckBiometrics || isDeviceSupported;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error checking biometrics: $e');
//       if (mounted) {
//         setState(() {
//           _canCheckBiometrics = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _authenticate() async {
//     if (!_canCheckBiometrics) {
//       _showToast('Biometric authentication not available');
//       return;
//     }
//
//     bool authenticated = false;
//     try {
//       authenticated = await auth.authenticate(
//         localizedReason: 'Please authenticate to access the app',
//         authMessages: const <AuthMessages>[
//           AndroidAuthMessages(
//             signInTitle: 'Biometric Authentication',
//             cancelButton: 'Cancel',
//             signInHint: 'Verify your identity',
//           ),
//           IOSAuthMessages(
//             cancelButton: 'Cancel',
//           ),
//         ],
//         biometricOnly: false,
//         sensitiveTransaction: false,
//       );
//
//       if (authenticated) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('isLoggedIn', true);
//
//         if (mounted) {
//           _showToast('Login successful');
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const HomeScreen()),
//           );
//         }
//       } else {
//         _showToast('Something went wrong, login again');
//       }
//     } on PlatformException catch (e) {
//       debugPrint('Authentication error: ${e.code} - ${e.message}');
//       _showToast('Something went wrong, login again');
//     } catch (e) {
//       debugPrint('Unexpected error: $e');
//       _showToast('Something went wrong, login again');
//     }
//   }
//
//   void _showToast(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           duration: const Duration(seconds: 2),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Login'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.fingerprint,
//                 size: 100,
//                 color: Colors.deepPurple,
//               ),
//               const SizedBox(height: 60),
//               ElevatedButton.icon(
//                 onPressed: _canCheckBiometrics ? _authenticate : null,
//                 icon: const Icon(Icons.login, size: 24),
//                 label: const Text(
//                   'Authenticate',
//                   style: TextStyle(fontSize: 18),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 48,
//                     vertical: 20,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               if (!_canCheckBiometrics) ...[
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Biometric authentication not available',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;
//   String _recognizedText = '';
//   bool _speechEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }
//
//   Future<void> _initSpeech() async {
//     try {
//       // Request microphone permission
//       final status = await Permission.microphone.request();
//       if (status.isGranted) {
//         _speechEnabled = await _speech.initialize(
//           onError: (error) => debugPrint('Speech error: $error'),
//           onStatus: (status) {
//             debugPrint('Speech status: $status');
//           },
//         );
//         setState(() {});
//       } else {
//         _showToast('Microphone permission denied');
//       }
//     } catch (e) {
//       debugPrint('Error initializing speech: $e');
//       _showToast('Error initializing speech recognition');
//     }
//   }
//
//   Future<void> _startListening() async {
//     if (!_speechEnabled) {
//       _showToast('Speech recognition not available');
//       return;
//     }
//
//     try {
//       await _speech.listen(
//         onResult: (result) {
//           setState(() {
//             _recognizedText = result.recognizedWords;
//           });
//         },
//         listenFor: const Duration(seconds: 30),
//         pauseFor: const Duration(seconds: 5),
//         localeId: 'en_US',
//       );
//       setState(() {
//         _isListening = true;
//       });
//     } catch (e) {
//       debugPrint('Error starting listening: $e');
//       _showToast('Error starting speech recognition');
//     }
//   }
//
//   Future<void> _stopListening() async {
//     try {
//       await _speech.stop();
//       setState(() {
//         _isListening = false;
//       });
//     } catch (e) {
//       debugPrint('Error stopping listening: $e');
//     }
//   }
//
//   void _toggleListening() {
//     if (_isListening) {
//       _stopListening();
//     } else {
//       _startListening();
//     }
//   }
//
//   void _showToast(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           duration: const Duration(seconds: 2),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   Future<void> _logout(BuildContext context) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', false);
//
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Logged out successfully'),
//             duration: Duration(seconds: 2),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const AuthScreen()),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error logging out: $e');
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Error logging out'),
//             duration: Duration(seconds: 2),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _speech.stop();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('Copilot'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () => _logout(context),
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_recognizedText.isEmpty)
//                 const Text(
//                   'Tap the microphone to start speaking',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey,
//                   ),
//                   textAlign: TextAlign.center,
//                 )
//               else
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.deepPurple.shade50,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.deepPurple.shade200,
//                       width: 2,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       const Icon(
//                         Icons.chat_bubble_outline,
//                         size: 40,
//                         color: Colors.deepPurple,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         _recognizedText,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black87,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               if (_isListening) ...[
//                 const SizedBox(height: 30),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 12,
//                       height: 12,
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     const Text(
//                       'Listening...',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.red,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _speechEnabled ? _toggleListening : null,
//         backgroundColor: _isListening ? Colors.red : Colors.deepPurple,
//         child: Icon(
//           _isListening ? Icons.mic : Icons.mic_none,
//           size: 32,
//         ),
//       ),
//     );
//   }
// }
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:local_auth/local_auth.dart';
// // import 'package:local_auth_android/local_auth_android.dart';
// // import 'package:local_auth_ios/local_auth_ios.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // void main() {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Copilot',
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //         useMaterial3: true,
// //       ),
// //       home: const AuthScreen(),
// //     );
// //   }
// // }
// //
// // class AuthScreen extends StatefulWidget {
// //   const AuthScreen({super.key});
// //
// //   @override
// //   State<AuthScreen> createState() => _AuthScreenState();
// // }
// //
// // class _AuthScreenState extends State<AuthScreen> {
// //   final LocalAuthentication auth = LocalAuthentication();
// //   bool _canCheckBiometrics = false;
// //   bool _isLoading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeAuth();
// //   }
// //
// //   Future<void> _initializeAuth() async {
// //     await Future.delayed(const Duration(milliseconds: 500));
// //     await _checkBiometrics();
// //     await _checkIfLoggedIn();
// //     setState(() {
// //       _isLoading = false;
// //     });
// //   }
// //
// //   Future<void> _checkIfLoggedIn() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
// //       if (isLoggedIn && mounted) {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => const HomeScreen()),
// //         );
// //       }
// //     } catch (e) {
// //       debugPrint('Error checking login status: $e');
// //     }
// //   }
// //
// //   Future<void> _checkBiometrics() async {
// //     try {
// //       final canCheckBiometrics = await auth.canCheckBiometrics;
// //       final isDeviceSupported = await auth.isDeviceSupported();
// //
// //       if (mounted) {
// //         setState(() {
// //           _canCheckBiometrics = canCheckBiometrics || isDeviceSupported;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint('Error checking biometrics: $e');
// //       if (mounted) {
// //         setState(() {
// //           _canCheckBiometrics = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   Future<void> _authenticate() async {
// //     if (!_canCheckBiometrics) {
// //       _showToast('Biometric authentication not available');
// //       return;
// //     }
// //
// //     bool authenticated = false;
// //     try {
// //       authenticated = await auth.authenticate(
// //         localizedReason: 'Please authenticate to access the app',
// //         authMessages: const <AuthMessages>[
// //           AndroidAuthMessages(
// //             signInTitle: 'Biometric Authentication',
// //             cancelButton: 'Cancel',
// //             signInHint: 'Verify your identity',
// //           ),
// //           IOSAuthMessages(
// //             cancelButton: 'Cancel',
// //           ),
// //         ],
// //
// //         biometricOnly: false,
// //         sensitiveTransaction: false,
// //       );
// //
// //       if (authenticated) {
// //         final prefs = await SharedPreferences.getInstance();
// //         await prefs.setBool('isLoggedIn', true);
// //
// //         if (mounted) {
// //           _showToast('Login successful');
// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(builder: (context) => const HomeScreen()),
// //           );
// //         }
// //       } else {
// //         _showToast('Something went wrong, login again');
// //       }
// //     } on PlatformException catch (e) {
// //       debugPrint('Authentication error: ${e.code} - ${e.message}');
// //       _showToast('Something went wrong, login again');
// //     } catch (e) {
// //       debugPrint('Unexpected error: $e');
// //       _showToast('Something went wrong, login again');
// //     }
// //   }
// //
// //   void _showToast(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           duration: const Duration(seconds: 2),
// //           behavior: SnackBarBehavior.floating,
// //         ),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isLoading) {
// //       return const Scaffold(
// //         body: Center(
// //           child: CircularProgressIndicator(),
// //         ),
// //       );
// //     }
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
// //         title: const Text('Login'),
// //         centerTitle: true,
// //       ),
// //       body: Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(24.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 Icons.fingerprint,
// //                 size: 100,
// //                 color: Colors.deepPurple,
// //               ),
// //               const SizedBox(height: 60),
// //               ElevatedButton.icon(
// //                 onPressed: _canCheckBiometrics ? _authenticate : null,
// //                 icon: const Icon(Icons.login, size: 24),
// //                 label: const Text(
// //                   'Authenticate',
// //                   style: TextStyle(fontSize: 18),
// //                 ),
// //                 style: ElevatedButton.styleFrom(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 48,
// //                     vertical: 20,
// //                   ),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //               ),
// //               if (!_canCheckBiometrics) ...[
// //                 const SizedBox(height: 20),
// //                 const Text(
// //                   'Biometric authentication not available',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: Colors.red,
// //                     fontSize: 14,
// //                   ),
// //                 ),
// //               ],
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class HomeScreen extends StatelessWidget {
// //   const HomeScreen({super.key});
// //
// //   Future<void> _logout(BuildContext context) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       await prefs.setBool('isLoggedIn', false);
// //
// //       if (context.mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Logged out successfully'),
// //             duration: Duration(seconds: 2),
// //             behavior: SnackBarBehavior.floating,
// //           ),
// //         );
// //
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => const AuthScreen()),
// //         );
// //       }
// //     } catch (e) {
// //       debugPrint('Error logging out: $e');
// //       if (context.mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Error logging out'),
// //             duration: Duration(seconds: 2),
// //             behavior: SnackBarBehavior.floating,
// //           ),
// //         );
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
// //         title: const Text('Copilot'),
// //         centerTitle: true,
// //         actions: [
// //           IconButton(
// //             onPressed: () => _logout(context),
// //             icon: const Icon(Icons.logout),
// //             tooltip: 'Logout',
// //           ),
// //         ],
// //       ),
// //       body: const Center(
// //         child: Text(
// //           'Welcome to Copilot',
// //           style: TextStyle(
// //             fontSize: 24,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }