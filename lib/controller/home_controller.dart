import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iMirAI/model/sessions_model.dart';
import 'package:iMirAI/model/session_chat_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
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
    'Generate Document',
  ];
  var selectedSuggestions = <String>[].obs;
  var userName = '';
  String sessionId = '';
  var sessionsList = SessionsModel().obs;

  // Store processed Excel data for reuse with different questions
  Map<String, dynamic>? storedDataJson;

  final apiService = ApiService();

  Future<void> init() async {
    userName =
        await SharedPrefManager.instance.getStringAsync(
          SharedPrefManager.username,
        ) ??
            '';
    print("aski"+userName);
    // await _initSpeech();
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
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    init();
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

  Future<void> _initSpeech(BuildContext context) async {
    try {
      final status = await Permission.microphone.status;

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
          _showToast('Speech recognition not available on this device', context);
        }
      } else {
        // Don't request permission or show dialog on init
        // Wait until user actually tries to use voice feature
        speechEnabled.value = false;
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      _showToast('Error initializing speech recognition', context);
    }
  }

  Future<void> startListening(BuildContext context) async {
    debugPrint('🎤 startListening called');

    // Initialize speech if not already done
    if (!speechEnabled.value) {
      await _initSpeech(context);
    }

    if (!speechEnabled.value) {
      _showToast('Speech recognition not available', context);
      return;
    }

    if (isListening.value) {
      debugPrint('🎤 Already listening');
      return;
    }

    try {
      debugPrint('🎤 Starting speech recognition...');
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
      _showToast('Error starting speech recognition', context);
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

  void _showToast(String message, BuildContext context) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        duration: const Duration(seconds: 2),

        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPermissionDialog(String title, String message) {
    if (Get.context == null) return;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
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

              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },

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
    if (searchController.text.trim().isEmpty && selectedSuggestions.isEmpty)
      return;

    String prompt = '';
    if (selectedSuggestions.isNotEmpty) {
      prompt += '[${selectedSuggestions.join(", ")}] ';
    }
    prompt += searchController.text;

    final userMessage = prompt;
    messages.add(
      ChatMessage(
        text: {'answer': userMessage},
        isUser: true,
        isLoading: false,
      ),
    );

    // Clear inputs
    searchController.clear();
    selectedSuggestions.clear();
    scrollToBottom();

    isLoading.value = true;
    try {
      ApiResponse response = await apiService.multipartRequest(
        endpoint: Endpoints.ask,
        fields: {
          "question": userMessage,
          "sessionId": sessionId,
          "username": userName,
          "File": '',
        },
      );

      bool result = apiService.showApiResponse(
        context: context,
        response: response,
        codes: {ApiCode.requestTimeout1: true},
      );

      if (result && response.data != null) {
        messages.add(
          ChatMessage(text: {'answer': response.data!["answer"]}, isUser: false, isLoading: false),
        );
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
      if (response.code == ApiCode.success200.index) {
        SessionsModel model = SessionsModel.fromJson(response.data);
        if (model.sessions != null) {
          model.sessions!.sort((a, b) {
            DateTime dateA = a.updatedAt != null
                ? DateTime.tryParse(a.updatedAt!) ?? DateTime(0)
                : DateTime(0);
            DateTime dateB = b.updatedAt != null
                ? DateTime.tryParse(b.updatedAt!) ?? DateTime(0)
                : DateTime(0);
            return dateB.compareTo(dateA); // Newest first
          });
        }
        sessionsList.value = model;
      }
    } finally {
      isSessionsLoading.value = false;
    }
  }

  Future<void> reloadMessage(BuildContext context, int index) async {
    if (index <= 0 || messages[index].isUser) return;

    final userMessage = messages[index - 1].text;

    // Set message to loading state
    messages[index] = ChatMessage(
      text: {'answer': ''},
      isUser: false,
      isLoading: true,
    );
    messages.refresh();

    try {
      ApiResponse response = await apiService.multipartRequest(
        endpoint: Endpoints.ask,
        fields: {
          "question": userMessage['answer']?.toString() ?? "",
          "sessionId": sessionId,
          "username": userName,
          "File": '',
        },
      );

      bool result = apiService.showApiResponse(
        context: context,
        response: response,
        codes: {ApiCode.requestTimeout1: true},
      );

      if (result && response.data != null) {
        messages[index] = ChatMessage(
          text: {'answer': response.data!["answer"]},
          isUser: false,
          isLoading: false,
        );
        messages.refresh();
      } else {
        // Restore original message if failed or handle error
        // For now just stop loading
        messages[index] = ChatMessage(
          text: {'answer': "Failed to reload. Please try again."},
          isUser: false,
          isLoading: false,
        );
        messages.refresh();
      }
    } catch (e) {
      SnackBarWidget.showError(context);
      messages[index] = ChatMessage(
        text: {'answer': "Error occurred during reload."},
        isUser: false,
        isLoading: false,
      );
      messages.refresh();
    }
  }

  Future<void> editSessionTitleApi(
      BuildContext context,
      String sessionId,
      String newTitle,
      ) async {
    try {
      isSessionsLoading.value = true;
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        endpoint: Endpoints.updateSessionTitle,
        body: {"name": newTitle, "username": userName, "session_id": sessionId},
        useFormData: true,
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
        body: {"username": userName, "session_id": sessionId},
        useFormData: true,
      );

      if (response.code == ApiCode.success200.index) {
        await getSessionsApi();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Session deleted')));
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
        messages[messageIndex].feedbackStatus = isThumbsUp
            ? 'liked'
            : 'disliked';
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
            Map<String, dynamic> msgText;
            if (msg.content is Map) {
              msgText = Map<String, dynamic>.from(msg.content);
            } else {
              msgText = {'answer': msg.content ?? ""};
            }

            messages.add(
              ChatMessage(
                text: msgText,
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
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        isLoading.value = true;
        PlatformFile file = result.files.first;

        messages.add(
          ChatMessage(
            text: {
              'answer': "Uploaded file: ${file.name} (Ready for analysis)",
            },
            isUser: true,
            isLoading: false,
          ),
        );
        // Use the simplified processing flow from FileProcessorService
        final processedData = await FileProcessorService.processFile(file);

        debugPrint("File Processed: ${jsonEncode(processedData)}");

        // Extract file name without extension for table_name
        String fileNameNoExt = file.name;
        if (fileNameNoExt.contains('.')) {
          fileNameNoExt = fileNameNoExt.substring(
            0,
            fileNameNoExt.lastIndexOf('.'),
          );
        }

        // Store the processed data for reuse with different questions
        storedDataJson = processedData;
        addSuggestion(searchOptions[2]); // Automatically select "Get Insights"

        messages.add(
          ChatMessage(
            text: {
              "answer": "File *${file.name} uploaded and processed successfully!\n\nYou can now ask questions about the data in this file. (e.g., 'How many rows are there?')"
            },
            isUser: false,
            isLoading: false,
            hasRefresh: false,
          ),
        );

        _showToast("File ready for analysis.", context);
        scrollToBottom();
      }
    } catch (e) {
      _showToast("Error: ${e.toString()}", context);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> askDataInsightsQuestion(BuildContext context) async {
    if (searchController.text.trim().isEmpty) {
      _showToast("Please enter a question", context);
      return;
    }

    if (storedDataJson == null) {
      _showToast("Please upload an Excel file first", context);
      return;
    }

    final userQuestion = searchController.text.trim();

    // Add user message to chat
    messages.add(
      ChatMessage(
        text: {'answer': userQuestion},
        isUser: true,
        isLoading: false,
      ),
    );

    searchController.clear();
    hasText.value = false;
    scrollToBottom();

    isLoading.value = true;
    try {
      ApiResponse response = await apiService.request(
        method: ApiMethod.post,
        customUrl: true,
        endpoint: Endpoints.insightBaseUrl + Endpoints.dataInsights,
        body: {
          "SESSION_ID": sessionId,
          "QUESTION": userQuestion,
          "DATA_JSON": jsonEncode(storedDataJson),
        },
        useFormData: true,
      );

      if (response.code == ApiCode.success200.index) {
        if (response.data != null) {
          messages.add(
            ChatMessage(
              text: {"answer": _formatApiResponse(response.data)},
              isUser: false,
              isLoading: false,
              hasRefresh: false,
            ),
          );
        }
        _showToast("Insights generated successfully.", context);
      } else {
        _showToast("Failed to get insights.", context);
      }
    } catch (e) {
      debugPrint("Error calling Data Insights API: $e");
      _showToast("Error during insights generation.", context);
    } finally {
      isLoading.value = false;
      scrollToBottom();
    }
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
      _showPermissionDialog(
        'Camera Permission Required',
        'Please enable camera permission in settings to scan QR codes.',
      );
    }
    // If denied, native dialog already shown - no need for custom message
  }

  Future<void> openCamera(BuildContext context) async {
    // final status = await Permission.camera.request();
    // if (status.isGranted) {
      _showToast('Camera feature coming soon', context);
    // } else if (status.isPermanentlyDenied) {
    //   _showPermissionDialog(
    //     'Camera Permission Required',
    //     'Please enable camera permission in settings to use the camera.',
    //   );
    // }
    // If denied, native dialog already shown - no need for custom message
  }

  Future<void> openPhotos(BuildContext context) async {
    // final status = await Permission.photos.request();
    // if (status.isGranted) {
      _showToast('Photo picker feature coming soon', context);
    //   // TODO: Implement photo picker functionality
    // } else if (status.isPermanentlyDenied) {
    //   _showPermissionDialog(
    //     'Photos Permission Required',
    //     'Please enable photos permission in settings to access your photo library.',
    //   );
    // }
    // If denied, native dialog already shown - no need for custom message
  }
  Future<void> askQuestionApi(BuildContext context) async {
  if (searchController.text.trim().isEmpty) {
    _showToast("Please enter text before generating document", context);
    return;
  }

  final userMessage = searchController.text;
  messages.add(
    ChatMessage(
      text: {'answer': userMessage},
      isUser: true,
      isLoading: false,
    ),
  );

  String prompt = searchController.text;
  searchController.clear();
  scrollToBottom();

  isLoading.value = true;

  try {
    final url = Uri.parse(
      Endpoints.askQuestionBaseUrl +
          Endpoints.askQuestion.replaceAll(RegExp(r'/$'), ''),
    );

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {"Question": prompt},
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      // ================== DIRECTORY LOGIC (FIXED) ==================
      Directory baseDir;

      if (Platform.isAndroid) {
        baseDir = Directory('/storage/emulated/0/Download');
        if (!await baseDir.exists()) {
          baseDir = (await getExternalStorageDirectory())!;
        }
      } else if (Platform.isIOS) {
        baseDir = await getApplicationDocumentsDirectory();
      } else {
        baseDir = (await getDownloadsDirectory()) ??
            await getApplicationDocumentsDirectory();
      }

      // Create "pilog" folder
      final pilogDir = Directory('${baseDir.path}/pilog');
      if (!await pilogDir.exists()) {
        await pilogDir.create(recursive: true);
      }

      debugPrint('📁 Saving file to: ${pilogDir.path}');
      // ============================================================

      // ================== FILE NAME ==================
      String safeName = prompt
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .split(' ')
          .take(3)
          .join('_');

      if (safeName.isEmpty) safeName = "generated_doc";

      String fileName =
          "${safeName}_${DateTime.now().millisecondsSinceEpoch}.docx";
      // ============================================================

      final filePath = "${pilogDir.path}/$fileName";
      final file = File(filePath);

      await file.writeAsBytes(bytes);

      messages.add(
        ChatMessage(
          text: {
            'answer':
                "✅ Document saved as **$fileName**\n📁 Location: pilog folder"
          },
          isUser: false,
          isLoading: false,
          hasRefresh: false,
        ),
      );

      _showToast("Document saved in pilog folder", context);

      await OpenFile.open(filePath);
    } else {
      _showToast(
        "Failed to generate document. Status: ${response.statusCode}",
        context,
      );
    }
  } catch (e) {
    debugPrint("❌ Error generating document: $e");
    _showToast("Error during document generation.", context);
  } finally {
    isLoading.value = false;
    scrollToBottom();
  }
  }
  Future<void> sellNowApi(BuildContext context) async {
    String questionText = searchController.text.trim();
    String originalQuestion = questionText;

    // Add user message to chat if there's text
    if (questionText.isNotEmpty) {
      messages.add(
        ChatMessage(
          text: {'answer': questionText},
          isUser: true,
          isLoading: false,
        ),
      );
      searchController.clear();
      hasText.value = false;
      scrollToBottom();
    }

    isLoading.value = true;
    try {
      ApiResponse response;
      if (originalQuestion.isEmpty) {
        // Use existing chatWithDataMob api
        response = await apiService.request(
          method: ApiMethod.post,
          customUrl: true,
          endpoint: Endpoints.chatWithDataMobBaseUrl + Endpoints.chatWithDataMob,
          body: {
            "question": '',
            "sellnow": "sell",
          },
          useFormData: true,
        );
      } else {
        // Hit new chatWithData API
        response = await apiService.request(
          method: ApiMethod.post,
          customUrl: true,
          endpoint: Endpoints.chatWithDataBaseUrl + Endpoints.chatWithData,
          body: {
            "SESSION_ID": sessionId,
            "QUESTION": originalQuestion,
          },
          useFormData: true,
        );
      }

      if (response.code == ApiCode.success200.index && response.data != null) {
        // Case A: Suggestion list (Usually from empty question call)
        if (response.data['SUGGESTED_QUESTIONS'] is List) {
          List<String> suggestions = List<String>.from(response.data['SUGGESTED_QUESTIONS']);
          messages.add(
            ChatMessage(
              text: {'answer': "Choose a question or type your own:"},
              isUser: false,
              isLoading: false,
              suggestions: suggestions,
              hasRefresh: false,
            ),
          );
        }
        // Case B: Data or Map
        else if (response.data is Map) {
          messages.add(
            ChatMessage(
              text: {"answer": _formatApiResponse(response.data)},
              isUser: false,
              isLoading: false,
              hasRefresh: false,
            ),
          );
        }
      } else if (response.code != ApiCode.success200.index) {
        _showToast("No response from service.", context);
      }
    } catch (e) {
      debugPrint("Error in sellNowApi: $e");
      _showToast("Network error in service.", context);
    } finally {
      isLoading.value = false;
      scrollToBottom();
    }
  }

  void addTextToSearch(String text) {
    bool wasSellNow = selectedSuggestions.contains(searchOptions[1]);
    searchController.text = text;
    hasText.value = true;
    selectedSuggestions.clear();
    if (wasSellNow) {
      selectedSuggestions.add(searchOptions[1]);
    }
  }
  String _formatApiResponse(dynamic data) {
    if (data == null) return "";

    if (data is Map && data.containsKey("ANSWER")) {
      var answer = data["ANSWER"];
      if (answer is List) {
        return answer.join("\n");
      } else if (answer is Map) {
        return _convertMapToHtmlTable(Map<String, dynamic>.from(answer));
      } else {
        return answer.toString();
      }
    }

    if (data is Map) {
      return jsonEncode(data);
    }

    return data.toString();
  }

  String _convertMapToHtmlTable(Map<String, dynamic> answerMap) {
    if (answerMap.isEmpty) return "No data available";
    
    List<String> headers = answerMap.keys.toList();
    int maxRows = 0;
    for (var value in answerMap.values) {
      if (value is List) {
        if (value.length > maxRows) maxRows = value.length;
      } else {
        if (1 > maxRows) maxRows = 1;
      }
    }

    StringBuffer htmlBuffer = StringBuffer();
    htmlBuffer.write("<table border='1'>");
    htmlBuffer.write("<tr>");
    for (String header in headers) {
      htmlBuffer.write("<th>$header</th>");
    }
    htmlBuffer.write("</tr>");

    for (int i = 0; i < maxRows; i++) {
      htmlBuffer.write("<tr>");
      for (String header in headers) {
        var value = answerMap[header];
        String cellValue = "";
        if (value is List) {
          if (i < value.length) {
            cellValue = value[i].toString();
          }
        } else if (i == 0) {
          cellValue = value.toString();
        }
        htmlBuffer.write("<td>$cellValue</td>");
      }
      htmlBuffer.write("</tr>");
    }
    htmlBuffer.write("</table>");
    return htmlBuffer.toString();
  }
}

