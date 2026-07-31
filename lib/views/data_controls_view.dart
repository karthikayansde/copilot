import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/home_controller.dart';
import '../services/api/endpoints.dart';
import '../widgets/button_widgets.dart';

class DataControlsView extends StatefulWidget {
  const DataControlsView({super.key});

  @override
  State<DataControlsView> createState() => _DataControlsViewState();
}

class _DataControlsViewState extends State<DataControlsView> {
  final controller = Get.find<HomeController>();
  final RxBool isExporting = false.obs;

  Future<void> _exportChatHistory() async {
    final cs = Theme.of(context).colorScheme;
    try {
      isExporting.value = true;

      final String username = controller.userName.value;
      if (username.isEmpty) {
        Get.snackbar(
          'Error',
          'Username not found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: cs.errorContainer,
          colorText: cs.onErrorContainer,
        );
        return;
      }

      final String url =
          '${Endpoints.exportChats}$username';
      debugPrint('Exporting chats from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
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

        try {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          debugPrint('External download failed: $e');
        }

        Get.snackbar(
          'Success',
          'Chat history exported successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: cs.inverseSurface,
          colorText: cs.onInverseSurface,
          messageText: Text(
            'The file has been downloaded and is ready to view.',
            style: TextStyle(
                color: cs.onInverseSurface.withOpacity(0.7), fontSize: 13),
          ),
          mainButton: TextButton(
            onPressed: () => OpenFile.open(filePath),
            child: Text(
              'OPEN FILE',
              style: TextStyle(
                  color: cs.primaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to export chat history. Server returned ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: cs.errorContainer,
          colorText: cs.onErrorContainer,
        );
      }
    } catch (e) {
      debugPrint('Error exporting chats: $e');
      Get.snackbar(
        'Error',
        'An error occurred while exporting chat history.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cs.errorContainer,
        colorText: cs.onErrorContainer,
      );
    } finally {
      isExporting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Data Controls',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: cs.onSurface, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
            () => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download your complete chat history as a document file.',
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BasicButtonWidget(
                    onPressed: () {
            (isExporting.value ? null : _exportChatHistory());
            },
                    label: "Export & Download",
                  ),
                  const SizedBox(height: 16),
                  _buildAestheticNote(cs),
                ],
              ),
              if (isExporting.value)
                Center(
                  child: CircularProgressIndicator(color: cs.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAestheticNote(ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, color: cs.onSurface.withOpacity(0.4), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Your export will be saved as a .docx file containing all your conversations with iMirAI.',
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withOpacity(0.5),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}