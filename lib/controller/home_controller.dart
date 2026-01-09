import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iMirAI/model/sessions_model.dart';
import 'package:iMirAI/model/session_chat_model.dart';
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
import '../model/chat_message.dart';
import '../services/file_processor_service.dart';
import '../views/qr_scanner_view.dart';
import 'package:file_picker/file_picker.dart';


class HomeController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  var isLoading = false.obs;
  var isSessionsLoading = false.obs;
  var isMessageLoading = false.obs;
  var isListening = false.obs;
  var speechEnabled = false.obs;
  var hasText = false.obs;
  var messages = <ChatMessage>[].obs;
  final List<String> searchOptions = [
    'IntelAgent',
    'SellNow',
    'Get Insights',
    'Generate Document'
  ];
  var selectedSuggestions = <String>[].obs;
  var userName = '';
  String sessionId = '';
  var sessionsList = SessionsModel().obs;

  final apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    userName =
        await SharedPrefManager.instance.getStringAsync(
          SharedPrefManager.username,
        ) ??
        '';
    await _initSpeech();
    await _getSessionId();
    await getSessionsApi();
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

  Future<void> _getSessionId({bool force = false}) async {
    if (sessionId.isEmpty || force) {
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

      sessionId = String.fromCharCodes(
        Iterable.generate(
          10,
          (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
        ),
      );
    }
  }

  Future<void> _initSpeech() async {
    try {
      final status = await Permission.microphone.request();

      if (status.isGranted) {
        final initialized = await _speech.initialize(
          onError: (error) {
            debugPrint('Speech error: $error');
            isListening.value = false;
          },
          onStatus: (status) {
            debugPrint('Speech status: $status');
            if (status == 'notListening' || status == 'done') {
              isListening.value = false;
            }
          },
        );
        speechEnabled.value = initialized;
        if (!initialized) {
          _showToast('Speech recognition not available on this device');
        }
      } else if (status.isDenied) {
        _showToast('Microphone permission denied');
      } else if (status.isPermanentlyDenied) {
        _showToast('Microphone permission permanently denied. Please enable in settings.');
        openAppSettings();
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      _showToast('Error initializing speech recognition');
    }
  }

  Future<void> startListening() async {
    if (!speechEnabled.value) {
      await _initSpeech();
    }
    
    if (!speechEnabled.value) {
      _showToast('Speech recognition not available');
      return;
    }

    if (isListening.value) {
      return;
    }

    try {
      isListening.value = true;
      await _speech.listen(
        onResult: (result) {
          searchController.text = result.recognizedWords;
          hasText.value = result.recognizedWords.isNotEmpty;
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
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

  void addSuggestion(String suggestion) {
    selectedSuggestions.clear();
    selectedSuggestions.add(suggestion);
  }

  void removeSuggestion(String suggestion) {
    selectedSuggestions.remove(suggestion);
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

              onPressed: (){

        Navigator.of(dialogContext).pop(true);
        } ,

              label: AppStrings.logout,
            ),
          ],
        );
      },
    );

    // If user confirmed logout

    if (shouldLogout == true) {
      try {
        await SharedPrefManager.instance.logout();

        messages.clear();
        searchController.clear();
        sessionId = '';
        userName = '';
        isListening.value = false;
        speechEnabled.value = false;
        hasText.value = false;
        isLoading.value = false;
        _speech.stop();
        // ... (logout methods remain same)
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
      if (searchController.text.trim().isEmpty && selectedSuggestions.isEmpty) return;

      String prompt = '';
      if (selectedSuggestions.isNotEmpty) {
        prompt += '[${selectedSuggestions.join(", ")}] ';
      }
      prompt += searchController.text;

    final userMessage = prompt;
    messages.add(ChatMessage(text: userMessage, isUser: true, isLoading: false));
    
    // Clear inputs
    searchController.clear();
    selectedSuggestions.clear();
    scrollToBottom();

      isLoading.value = true;
      try {
        ApiResponse response = await apiService.request(
          method: ApiMethod.post,
          endpoint: Endpoints.ask,
          body: {
            "question": userMessage,
            "sessionId": sessionId,
            "username": userName,
          },
        );


      bool result = apiService.showApiResponse(
        context: context,
        response: response,
        codes: {ApiCode.requestTimeout1: true},
      );

      if (result && response.data != null) {
        messages.add(ChatMessage(
          text: response.data!,
          isUser: false,
          isLoading: false,
        ));
        scrollToBottom();

        // Refresh sessions list if this was the first exchange in a new session
        if (messages.length <= 2) {
          getSessionsApi();
        }
      }
    } catch (e) {
      SnackBarWidget.showError(context);
    } finally {
      isLoading.value = false;
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> getSessionsApi() async {
    try {
      isSessionsLoading.value = true;
      ApiResponse response = await apiService.request(
        method: ApiMethod.get,
        endpoint: "${Endpoints.sessions}$userName",
      );
      if(response.code == ApiCode.success200.index){
        SessionsModel model = SessionsModel.fromJson(response.data);
        if (model.sessions != null) {
          model.sessions!.sort((a, b) {
            DateTime dateA = a.updatedAt != null ? DateTime.tryParse(a.updatedAt!) ?? DateTime(0) : DateTime(0);
            DateTime dateB = b.updatedAt != null ? DateTime.tryParse(b.updatedAt!) ?? DateTime(0) : DateTime(0);
            return dateB.compareTo(dateA); // Newest first
          });
        }
        sessionsList.value = model;
      }
    } catch (e) {
    } finally {
      isSessionsLoading.value = false;
    }
  }

  Future<void> reloadMessage(BuildContext context, int index) async {
    if (index <= 0 || messages[index].isUser) return;
    
    final userMessage = messages[index - 1].text;
    
    // Set message to loading state
    messages[index] = ChatMessage(text: {'answer': ''}, isUser: false, isLoading: true);
    messages.refresh();
    
    try {
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        endpoint: Endpoints.ask,
        body: {
          "question": userMessage,
          "sessionId": sessionId,
          "username": userName,
        },
      );

      bool result = apiService.showApiResponse(
        context: context,
        response: response,
        codes: {ApiCode.requestTimeout1: true},
      );

      if (result && response.data != null) {

        messages[index] = ChatMessage(
          text: response.data!,
          isUser: false,
          isLoading: false,
        );
        messages.refresh();
      } else {
        // Restore original message if failed or handle error
        // For now just stop loading
        messages[index] = ChatMessage(text: {'answer': "Failed to reload. Please try again."}, isUser: false, isLoading: false);
        messages.refresh();
      }
    } catch (e) {
      SnackBarWidget.showError(context);
      messages[index] = ChatMessage(text: {'answer': "Error occurred during reload."}, isUser: false, isLoading: false);
      messages.refresh();
    }
  }

  Future<void> editSessionTitleApi(BuildContext context, String sessionId, String newTitle) async {
    try {
      isSessionsLoading.value = true;
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        endpoint: Endpoints.updateSessionTitle,
        body: {
          "name": newTitle,
          "username": userName,
          "session_id": sessionId,
        },
        useFormData: true
      );

      if (response.code == ApiCode.success200.index) {
        await getSessionsApi();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session title updated')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) SnackBarWidget.showError(context);
    } finally {
      isSessionsLoading.value = false;
    }
  }

  Future<void> deleteSessionApi(BuildContext context, String sessionId) async {
    try {
      isSessionsLoading.value = true;
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        endpoint: Endpoints.deleteSession,
        body: {
          "username": userName,
          "session_id": sessionId
        },
        useFormData: true
      );

      if (response.code == ApiCode.success200.index) {
        await getSessionsApi();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session deleted')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) SnackBarWidget.showError(context);
    } finally {
      isSessionsLoading.value = false;
    }
  }

  Future<bool> saveFeedbackApi({
    required BuildContext context,
    required String question,
    required bool isThumbsUp,
    required double percentage,
    required int messageIndex,
    String? reason,
  }) async {
    try {
      isLoading.value = true;
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        endpoint: Endpoints.saveFeedback,
        body: {
          "question": question,
          "Thumbs_up": isThumbsUp ? "1" : "0",
          "Thumbs_down": isThumbsUp ? "0" : "1",
          "Percentage": percentage.toInt().toString(),
          "sessionId": sessionId,
          "reason": reason ?? "",
        },
        useFormData: false,
      );

      if (response.code == ApiCode.success200.index) {
        messages[messageIndex].feedbackStatus = isThumbsUp ? 'liked' : 'disliked';
        messages.refresh();
        return true;
      }
      return false;
    } catch (e) {
      if (context.mounted) SnackBarWidget.showError(context);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSessionChatsApi(String sessionId) async {
    try {
      this.sessionId = sessionId;
      isLoading.value = true;
      messages.clear();
      searchController.clear();
      selectedSuggestions.clear();

      ApiResponse response = await apiService.request(
        method: ApiMethod.get,
        endpoint: "${Endpoints.getSessionChats}$sessionId",
      );

      if (response.code == ApiCode.success200.index) {
        final sessionChat = SessionChatModel.fromJson(response.data);
        if (sessionChat.messages != null) {
          for (var msg in sessionChat.messages!) {
            messages.add(
              ChatMessage(
                text: {'answer':msg.content ?? ""},
                isUser: msg.role == "user",
                isLoading: false,
              ),
            );
          }
          messages.refresh();
        }
        scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error getting session chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void startNewChat() {
    _getSessionId(force: true);
    messages.clear();
    searchController.clear();
    selectedSuggestions.clear();
    hasText.value = false;
  }

  Future<void> pickAndProcessFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xlsx', 'xls', 'csv', 'docx', 'doc', 'txt'],
      );

      if (result != null) {

        isLoading.value = true;
        PlatformFile file = result.files.first;

        messages.add(ChatMessage(
            text: {'answer': "Uploaded file: ${file.name} (Ready for analysis)"},
            isUser: true,
            isLoading: false
        ));
        // Use the 5-step processing flow from FileProcessorService
        final processedData = await FileProcessorService.processFile(file);

        if (processedData['status'] == 'success') {
          debugPrint("File Processed: ${file.name}");

          // Extract file name without extension for table_name
          String fileNameNoExt = file.name;
          if (fileNameNoExt.contains('.')) {
            fileNameNoExt = fileNameNoExt.substring(0, fileNameNoExt.lastIndexOf('.'));
          }

          // Step: Data Insights API Call
          try {
            ApiResponse response = await apiService.request(
              method: ApiMethod.post,
              customUrl: true,
              endpoint: Endpoints.insightBaseUrl+Endpoints.dataInsights,
              body: {
                "response_id": sessionId,
                "table_name": fileNameNoExt.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''),
                "data_table": jsonEncode([
                  {"ID": "A4", "Value": 3},
                  {"ID": "B2", "Value": 5}
                ])
                // jsonEncode(processedData['body']),
              },
              useFormData: true,
            );

            if (response.code == ApiCode.success200.index) {
              if (response.data != null && response.data != null) {
                messages.add(ChatMessage(
                  text: response.data,
                  isUser: false,
                  isLoading: false,
                  hasRefresh: false
                ));
              }
              _showToast("File processed and insights generated successfully.");
            } else {
              _showToast("File standardized, but insights API failed.");
            }
          } catch (e) {
            debugPrint("Error calling Data Insights API: $e");
            _showToast("Error during insights generation.");
          }
          scrollToBottom();
        } else {
          _showToast("Error: ${processedData['message']}");
          
          // If encrypted, you might want to show a dialog for password
          if (processedData['error_type'] == 'ENCRYPTED') {
             _showPasswordDialog(context, file);
          }
        }
      }
    } catch (e) {
      _showToast("Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void _showPasswordDialog(BuildContext context, PlatformFile file) {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Protected File"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("This file is password protected. Please enter the password:"),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast("Manual password handling would go here.");
            },
            child: const Text("Unlock"),
          ),
        ],
      ),
    );
  }

  Future<void> scanQRCode(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final result = await Get.to(() => const QRScannerView());
      if (result != null && result is String) {
        searchController.text = result;
        hasText.value = true;
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      _showToast('Camera permission denied');
    }
  }
}
