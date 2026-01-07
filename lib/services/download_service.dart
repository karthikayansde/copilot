import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

class DownloadService {
  static Future<String?> downloadFile({
    required String url,
    required String fileName,
    Function(int, int)? onProgress,
  }) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Get the download directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          // Navigate to Downloads folder
          if (directory != null) {
            directory = Directory('${directory.path}/Download');
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          // For Windows, Linux, macOS - use documents directory
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          Get.snackbar(
            'Error',
            'Could not access download directory',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }

        // Create directory if it doesn't exist
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Save the file
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        return file.path;
      } else {
        Get.snackbar(
          'Error',
          'Failed to download file: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Download failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }
}
