import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';

class FileProcessorService {
  /// Entry point to process the selected file following the 5-step flow.
  static Future<Map<String, dynamic>> processFile(PlatformFile file) async {
    final extension = file.extension?.toLowerCase();
    
    try {
      // Step 1: Format Categorization
      if (['xlsx', 'xls', 'csv'].contains(extension)) {
        return await _processTabularTrack(file);
      } else if (['pdf', 'docx', 'doc', 'txt'].contains(extension)) {
        return await _processNarrativeTrack(file);
      } else {
        throw Exception('Unsupported file format: .$extension');
      }
    } catch (e) {
      // Step 5: Handling Exceptions (Corrupt/Encrypted/Empty)
      if (e.toString().contains('password') || e.toString().contains('encrypted') || e.toString().contains('locked')) {
        return {
          'status': 'error',
          'error_type': 'ENCRYPTED',
          'message': 'This file is password-protected. Please provide the password.',
        };
      }
      return {
        'status': 'error',
        'error_type': 'PROCESSING_ERROR',
        'message': e.toString(),
      };
    }
  }

  // Step 2: Parsing Engines - Track A (Tabular)
  static Future<Map<String, dynamic>> _processTabularTrack(PlatformFile file) async {
    final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null || bytes.isEmpty) throw Exception('File is empty or could not be read.');

    final extension = file.extension?.toLowerCase();
    List<Map<String, dynamic>> rows = [];
    String? firstSheetName;

    if (extension == 'csv') {
      final csvString = utf8.decode(bytes);
      final csvData = const CsvToListConverter().convert(csvString);
      if (csvData.isEmpty) throw Exception('No data found in CSV.');
      
      final headers = csvData[0].map((e) => e.toString()).toList();
      for (var i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        final map = <String, dynamic>{};
        for (var j = 0; j < headers.length; j++) {
          map[headers[j]] = j < row.length ? row[j] : null;
        }
        rows.add(map);
      }
      firstSheetName = 'Default';
    } else {
      // Excel (xls, xlsx)
      final excel = Excel.decodeBytes(bytes);
      firstSheetName = excel.tables.keys.first;
      final sheet = excel.tables[firstSheetName]!;
      
      if (sheet.maxRows == 0) throw Exception('No data found in Excel sheet.');

      // Get headers from first row
      final headers = sheet.rows[0].map((e) => e?.value?.toString() ?? '').toList();
      
      for (var i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        final map = <String, dynamic>{};
        for (var j = 0; j < headers.length; j++) {
          map[headers[j]] = j < row.length ? row[j]?.value : null;
        }
        rows.add(map);
      }
    }

    return _consolidateJson(file, rows, sheetName: firstSheetName);
  }

  // Step 2: Parsing Engines - Track B (Narrative)
  static Future<Map<String, dynamic>> _processNarrativeTrack(PlatformFile file) async {
    final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null || bytes.isEmpty) throw Exception('File is empty or could not be read.');

    final extension = file.extension?.toLowerCase();
    String content = '';

    if (extension == 'txt') {
      content = utf8.decode(bytes);
    } else if (extension == 'pdf') {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      content = PdfTextExtractor(document).extractText();
      document.dispose();
    } else if (extension == 'docx' || extension == 'doc') {
      content = docxToText(bytes);
    }

    if (content.trim().isEmpty) throw Exception('Empty Files: Returns an error if no text is found.');

    // Stream Extraction: ignores page breaks and formatting, collapses into continuous text string
    content = content.replaceAll(RegExp(r'\f'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    return _consolidateJson(file, [content]);
  }

  // Step 3 & 4: Metadata Attachment & JSON Consolidation
  static Map<String, dynamic> _consolidateJson(PlatformFile file, dynamic body, {String? sheetName}) {
    return {
      'status': 'success',
      'header': {
        'name': file.name,
        'size': file.size,
        'format': file.extension,
        'upload_timestamp': DateTime.now().toIso8601String(),
        'sheet_name': sheetName,
        'intel_metadata': {
          'detected_language': 'en', // Optional placeholder
          'track': (body is List) ? 'Tabular' : 'Narrative',
        }
      },
      'body': body // Either List of Rows or String of Text
    };
  }
}
