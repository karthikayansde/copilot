// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
//
// class DownloadService {
//   static Future<String?> downloadFile({
//     required String url,
//     required String fileName,
//     Function(int, int)? onProgress,
//   }) async {
//     try {
//       final uri = Uri.parse(url);
//
//       // Try downloading the file directly first
//       try {
//         final response = await http.get(uri);
//
//         if (response.statusCode == 200) {
//           // Get the downloads directory
//           final directory = await getDownloadsDirectory();
//           if (directory == null) {
//             // Fallback to using url_launcher if downloads directory not available
//             return await _launchUrlFallback(uri);
//           }
//
//           final file = File('${directory.path}/$fileName');
//           await file.writeAsBytes(response.bodyBytes);
//
//           Get.snackbar(
//             'Success',
//             'File downloaded to Downloads',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             duration: const Duration(seconds: 3),
//           );
//           return file.path;
//         }
//       } catch (e) {
//         debugPrint('Direct download failed: $e, falling back to url_launcher');
//       }
//
//       // Fallback to url_launcher if direct download fails
//       return await _launchUrlFallback(uri);
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Download failed: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return null;
//     }
//   }
//
//   static Future<String?> _launchUrlFallback(Uri uri) async {
//     try {
//       // Use url_launcher to open the download URL in the browser / system handler
//       final canLaunch = await canLaunchUrl(uri);
//       if (!canLaunch) {
//         Get.snackbar(
//           'Error',
//           'Cannot open download link',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         return null;
//       }
//
//       final launched = await launchUrl(
//         uri,
//         mode: LaunchMode.externalApplication,
//       );
//
//       if (!launched) {
//         Get.snackbar(
//           'Error',
//           'Failed to open download link',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         return null;
//       }
//
//       // We don't manage the file path anymore, just indicate success
//       return uri.toString();
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Download failed: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return null;
//     }
//   }
// }
