import 'package:flutter/services.dart';

class AppInputFormatters {
  /// --- Regular Expressions ---
  // email
  static final RegExp emailPatternRegExp = RegExp( r"^(?![.])([a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+)(?<![.])@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[A-Za-z]{2,}$");
  // static final RegExp emailPatternRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
  // static final RegExp emailRegExp = RegExp(r'[a-zA-Z0-9@._-]');
  static final RegExp emailRegExp = RegExp(r"[a-zA-Z0-9@.!#\$%&'\*\+\-/=\?\^_`\{\|\}~]");
  // raw
  static final RegExp smallLettersRegExp = RegExp(r'[a-z]');
  static final RegExp capitalLettersRegExp = RegExp(r'[A-Z]');
  static final RegExp numbersRegExp = RegExp(r'[0-9]');
  static final RegExp decimalRegExp = RegExp(r'[0-9.]');
  static final RegExp spaceRegExp = RegExp(r'\s');
  static final RegExp newLineRegExp = RegExp(r'\n');
  static final RegExp punctuationAndSymbolsRegExp = RegExp(r'''[.,!?;:\-_'"\(\)\[\]\{\}@#\$%&\*\+=<>/\\|~`^]''');
  // combinations
  static final RegExp lettersRegExp = RegExp(r'[a-zA-Z]');
  static final RegExp lettersSpaceRegExp = RegExp(r'[a-zA-Z\s]');
  static final RegExp capitalAndNumbersRegExp = RegExp(r'[A-Z0-9]');
  static final RegExp lettersAndNumbersRegExp = RegExp(r'[a-zA-Z0-9]');
  static final RegExp lettersNumbersSpaceRegExp = RegExp(r'[a-zA-Z0-9\s]');
  static final RegExp lettersNumbersSymbolsRegExp  = RegExp(r'''[a-zA-Z0-9.,!?;:\-_'"\(\)\[\]\{\}@#\$%&\*\+=<>/\\|~`^]''');
  static final RegExp lettersNumbersSpaceSymbolsRegExp  = RegExp(r'''[a-zA-Z0-9\s.,!?;:\-_'"\(\)\[\]\{\}@#\$%&\*\+=<>/\\|~`^]''');

  /// --- Single Formatters ---
  static final TextInputFormatter emailFormat = FilteringTextInputFormatter.allow(emailRegExp);
  // raw
  static final TextInputFormatter smallLettersFormat= FilteringTextInputFormatter.allow(smallLettersRegExp);
  static final TextInputFormatter capitalLettersFormat= FilteringTextInputFormatter.allow(capitalLettersRegExp);
  static final TextInputFormatter numbersFormat= FilteringTextInputFormatter.allow(numbersRegExp);
  static final TextInputFormatter decimalFormat= FilteringTextInputFormatter.allow(decimalRegExp);
  static final TextInputFormatter spaceFormat= FilteringTextInputFormatter.allow(spaceRegExp);
  static final TextInputFormatter newLineFormat= FilteringTextInputFormatter.allow(newLineRegExp);
  static final TextInputFormatter punctuationAndSymbolsFormat = FilteringTextInputFormatter.allow(punctuationAndSymbolsRegExp);
  // combinations
  static final TextInputFormatter lettersFormat= FilteringTextInputFormatter.allow(lettersRegExp);
  static final TextInputFormatter lettersSpaceFormat= FilteringTextInputFormatter.allow(lettersSpaceRegExp);
  static final TextInputFormatter capitalAndNumbersFormat= FilteringTextInputFormatter.allow(capitalAndNumbersRegExp);
  static final TextInputFormatter lettersAndNumbersFormat= FilteringTextInputFormatter.allow(lettersAndNumbersRegExp);
  static final TextInputFormatter lettersNumbersSpaceFormat= FilteringTextInputFormatter.allow(lettersNumbersSpaceRegExp);
  static final TextInputFormatter lettersNumbersSymbolsFormat= FilteringTextInputFormatter.allow(lettersNumbersSymbolsRegExp);
  static final TextInputFormatter lettersNumbersSpaceSymbolsFormat= FilteringTextInputFormatter.allow(lettersNumbersSpaceSymbolsRegExp);

  static TextInputFormatter limitedText({required int maxLength}) {
    return LengthLimitingTextInputFormatter(maxLength);
  }

  /// --- Methods for Group Formatters ---
  static List<TextInputFormatter> email()=>[
    emailFormat,
  ];
}

class MaxNumericValueFormatter extends TextInputFormatter {
  final double maxValue;
  final int decimalPlaces;
  late final RegExp validCharacters;

  MaxNumericValueFormatter({
    required this.maxValue,
    required this.decimalPlaces,
  }) {
    validCharacters = RegExp(r'^\d*\.?\d{0,' '$decimalPlaces' r'}$');
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final newText = newValue.text;

    if (newText.isEmpty) return newValue;
    if (!validCharacters.hasMatch(newText)) return oldValue;

    final parsedValue = double.tryParse(newText);
    if (parsedValue == null) return oldValue;

    // Prevent decimals if equal to maxValue
    if (parsedValue == maxValue && newText.contains('.')) return oldValue;

    // Reject values above maxValue
    if (parsedValue > maxValue) return oldValue;

    return newValue;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(), // Convert to uppercase
      selection: newValue.selection,
    );
  }
}

// goals
// block Emoji
// block profanity and Hate Speech (optional)
// block special characters
// limit char count
// block next line
// block urls and links
// sql injection codes
// allow only needed characters

//   static final RegExp urlsRegExp = RegExp(
//       r'(http|https):\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?');
//   static final RegExp sqlInjectionRegExp = RegExp(
//       r'(select|insert|update|delete|drop|union|--|;)', caseSensitive: false);
//   static final RegExp profanityRegExp = RegExp(r'badword1|badword2', caseSensitive: false); // Add your profanity list here
