import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/home_controller.dart';
import '../services/api/endpoints.dart';
import '../widgets/button_widgets.dart';
import '../widgets/loading_widget.dart';

class DataControlsView extends StatefulWidget {
  const DataControlsView({super.key});

  @override
  State<DataControlsView> createState() => _DataControlsViewState();
}


class _DataControlsViewState extends State<DataControlsView> {
  final controller = Get.find<HomeController>();
  final RxBool isExporting = false.obs;

  Future<void> _exportChatHistory() async {
    try {
      isExporting.value = true;
      
      final String username = controller.userName.value;
      if (username.isEmpty) {
        Get.snackbar(
          'Error',
          'Username not found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final String url = '${Endpoints.baseUrl}${Endpoints.exportChats}$username';
      debugPrint('Exporting chats from: $url');

      // 1. Fetching the file to save locally
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Get directory to save the file
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        final String fileName = 'chat_history_$username.docx';
        final String filePath = '${directory.path}/$fileName';
        final File file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        // 2. Also triggering a system "Download" via URLLauncher for user accessibility
        // This makes it "download also" to the device's system download handler
        try {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          debugPrint('External download failed: $e');
          // We already saved it locally, so this is just a fallback/bonus
        }

        Get.snackbar(
          'Success',
          'Chat history exported successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: Colors.white,
          messageText: Text(
            'The file has been downloaded and is ready to view.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          mainButton: TextButton(
            onPressed: () => OpenFile.open(filePath),
            child: const Text(
              'OPEN FILE',
              style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to export chat history. Server returned ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error exporting chats: $e');
      Get.snackbar(
        'Error',
        'An error occurred while exporting chat history.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Data Controls',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.black.withOpacity(0.05), height: 1),
        ),
      ),
      body: Obx(
        () => Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download your complete chat history as a document file.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  BasicButtonWidget(
                    onPressed: () {
                      (isExporting.value ? null : _exportChatHistory());
                    },
                    label: "Export & Download Chat History",
                  ),
                  const SizedBox(height: 32),
                  _buildAestheticNote(),
                ],
              ),
              if (isExporting.value)
                Center(
                  child: CircularProgressIndicator(),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAestheticNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your export will be saved as a .docx file containing all your conversations with iMirAI.',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
