import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../core/theme/app_colors.dart';
import '../services/api/api_service.dart';
import '../services/api/endpoints.dart';
import '../services/shared_pref_manager.dart';
import '../utils/app_strings.dart';
import '../views/login_view.dart';
import '../widgets/button_widgets.dart';
import '../widgets/snack_bar_widget.dart';

class HomeController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController searchController = TextEditingController();
  
  var isLoading = false.obs;
  var isListening = false.obs;
  var speechEnabled = false.obs;
  var hasText = false.obs;
  var userName = '';
  String sessionId = '';

  final apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    init();
  }
  Future<void> init() async {
    _initSpeech();
    _getSessionId();
    userName = await SharedPrefManager.instance.getStringAsync(SharedPrefManager.username)??'';
    searchController.addListener(() {
      hasText.value = searchController.text.isNotEmpty;
    });
  }

  @override
  void onClose() {
    _speech.stop();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _getSessionId() async {
    if (sessionId.isEmpty) {
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      sessionId = String.fromCharCodes(Iterable.generate(
          10, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
    }
  }

  Future<void> _initSpeech() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        speechEnabled.value = await _speech.initialize(
          onError: (error) {
            debugPrint('Speech error: $error');
            isListening.value = false;
            // SnackBarWidget.showError(Get.context!); 
          },
          onStatus: (status) {
            debugPrint('Speech status: $status');
            if (status == 'notListening' || status == 'done') {
              isListening.value = false;
            }
          },
        );
      } else {
        _showToast('Microphone permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      _showToast('Error initializing speech recognition');
    }
  }

  Future<void> startListening() async {
    if (!speechEnabled.value) {
      _showToast('Speech recognition not available');
      return;
    }

    if (isListening.value) {
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          searchController.text = result.recognizedWords;
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      isListening.value = true;
    } catch (e) {
      debugPrint('Error starting listening: $e');
      isListening.value = false;
      _showToast('Error starting speech recognition');
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
      isListening.value = false;
    } catch (e) {
      debugPrint('Error stopping listening: $e');
      isListening.value = false;
    }
  }

  void clearText() {
    searchController.clear();
    // Listener will update hasText
  }

  void _showToast(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),

            BasicButtonWidget(
                height: 35,
                width: 100,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                label: AppStrings.logout
            )
          ],
        );
      },
    );

    // If user confirmed logout
    if (shouldLogout == true) {
      try {
        await SharedPrefManager.instance.logout();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        debugPrint('Error logging out: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error logging out'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
  
  Future<void> sendMessage(BuildContext context) async {
     debugPrint('Send button pressed');

     isLoading.value = true;
     try {
       ApiResponse response = await apiService.request(
           method: ApiMethod.post,
           endpoint: Endpoints.ask,
           body: {
             "question": searchController.text,
             "sessionId": sessionId,
             "username": userName
           }
       );

       bool result = apiService.showApiResponse(
         context: context,
         response: response,
         codes: {
           ApiCode.requestTimeout1: true,
         },
       );

       if (result) {
         isLoading.value = false;
       }
     } catch (e) {
       SnackBarWidget.showError(context);
     } finally {
       isLoading.value = false;
     }
  }
}
