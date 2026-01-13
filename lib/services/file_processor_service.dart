import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class FileProcessorService {
  /// Processes xlsx, xls, or csv and returns:
  /// { "key1": [val1, val2], "key2": [val3, val4] }
  static Future<Map<String, List<dynamic>>> processFile(PlatformFile file) async {
    final extension = file.extension?.toLowerCase();
    
    // Get bytes safely from either memory or disk
    final List<int>? rawBytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);

    if (rawBytes == null || rawBytes.isEmpty) {
      throw Exception('File is empty or could not be read.');
    }

    // Convert to Uint8List for better library compatibility
    final Uint8List bytes = Uint8List.fromList(rawBytes);

    if (extension == 'csv') {
      return _processCsv(bytes);
    } else if (extension == 'xlsx' || extension == 'xls') {
      // Check for legacy .xls magic numbers (D0 CF 11 E0)
      if (bytes.length > 4 && 
          bytes[0] == 0xD0 && bytes[1] == 0xCF && 
          bytes[2] == 0x11 && bytes[3] == 0xE0) {
        throw Exception('Legacy .xls format is not supported. Please save as .xlsx and try again.');
      }
      return _processExcel(bytes);
    } else {
      throw Exception('Unsupported format: $extension');
    }
  }

  static Map<String, List<dynamic>> _processCsv(Uint8List bytes) {
    try {
      final csvString = utf8.decode(bytes);
      final csvData = const CsvToListConverter().convert(csvString);
      if (csvData.isEmpty) return {};

      final rawHeaders = csvData[0].map((e) => e?.toString() ?? '').toList();
      final headers = _sanitizeHeaders(rawHeaders);
      final Map<String, List<dynamic>> result = {for (var h in headers) h: []};

      for (var i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        for (var j = 0; j < headers.length; j++) {
          final val = j < row.length ? row[j] : null;
          result[headers[j]]?.add(val?.toString() ?? "");
        }
      }
      return result;
    } catch (e) {
      throw Exception('Error parsing CSV: $e');
    }
  }

  static Map<String, List<dynamic>> _processExcel(Uint8List bytes) {
    try {
      // Safe decoding
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        throw Exception('Excel file has no visible sheets.');
      }

      // Access the first table safely
      final String firstSheetName = excel.tables.keys.first;
      final sheet = excel.tables[firstSheetName];
      
      if (sheet == null || sheet.rows.isEmpty) {
        return {};
      }

      final rows = sheet.rows;
      final rawHeaders = rows[0].map((e) => e?.value?.toString() ?? '').toList();
      final headers = _sanitizeHeaders(rawHeaders);
      final Map<String, List<dynamic>> result = {for (var h in headers) h: []};

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        for (var j = 0; j < headers.length; j++) {
          final cell = j < row.length ? row[j] : null;
          result[headers[j]]?.add(cell?.value?.toString() ?? "");
        }
      }
      return result;
    } catch (e) {
      // Catching the null check operator error from the library
      if (e.toString().contains('null')) {
        throw Exception('File structure is incompatible. Ensure it is a valid .xlsx file.');
      }
      throw Exception('Excel processing failed: $e');
    }
  }

  static List<String> _sanitizeHeaders(List<String> raw) {
    List<String> cleaned = [];
    Map<String, int> seen = {};
    for (var h in raw) {
      String name = h.trim().isEmpty ? "Column" : h.trim();
      if (seen.containsKey(name)) {
        seen[name] = seen[name]! + 1;
        cleaned.add("${name}_${seen[name]}");
      } else {
        seen[name] = 0;
        cleaned.add(name);
      }
    }
    return cleaned;
  }
}