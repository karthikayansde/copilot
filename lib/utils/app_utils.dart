import 'package:flutter/material.dart';

class AppUtils {
  /// Strips HTML tags from a string and decodes common entities.
  static String stripHtml(String htmlString) {
    if (htmlString.isEmpty) return htmlString;

    // Replace <br> and <br/> with newlines
    String result = htmlString.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    
    // Replace </p> and </div> with newlines to preserve some structure
    result = result.replaceAll(RegExp(r'</p>|</div>', caseSensitive: false), '\n');
    
    // Remove all other tags
    result = result.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Decode common HTML entities
    result = result.replaceAll('&nbsp;', ' ')
                   .replaceAll('&lt;', '<')
                   .replaceAll('&gt;', '>')
                   .replaceAll('&amp;', '&')
                   .replaceAll('&quot;', '"')
                   .replaceAll('&#39;', "'")
                   .replaceAll('&apos;', "'");
                   
    // Remove extra whitespace while keeping newlines
    final lines = result.split('\n');
    final cleanedLines = lines.map((line) => line.trim()).where((line) => line.isNotEmpty);
    
    return cleanedLines.join('\n').trim();
  }
}
