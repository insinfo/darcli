import './patterns.dart';
import 'package:html/parser.dart';

const String defaultPattern = WORD;

class StringUtils {
  /// Remove HTML tags from a String with html/parser
  static String stripHtml(String htmlString,
      {bool replaceMultiLineBreaksWithTwo = false}) {
    final document = parse(htmlString);
    var parsedString = document.documentElement?.text ?? '';
    print('StringUtils@stripHtml:\r\n$parsedString');
    if (replaceMultiLineBreaksWithTwo) {
      //https://stackoverflow.com/questions/10965433/regex-replace-multi-line-breaks-with-single-in-javascript
      final pattern = r'\n\s*\n\s*\n'; //  | r'\n\s*\n'
      final regex = RegExp(pattern, multiLine: true);
      parsedString = parsedString.replaceAll(regex, r'\n\n');
    }

    return parsedString;
  }

  /// Remove HTML tags from a String with RegExp
  static String stripHtmlIfNeeded(String text,
      {bool replaceMultiLineBreaksWithTwo = false}) {
    var parsedString = text;

    //replace multiple break lines
   // parsedString = text.trim().replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
    //replace multiple spaces to single
    parsedString = parsedString.replaceAll(RegExp(r"\s+"), " ");
    // replace Unicode Character '–' (U+2013)
    parsedString = parsedString.replaceAll(RegExp(r"–"), "-");

    parsedString = parsedString
        .replaceAll(RegExp(r'<p[^>]*>'), '')
        .replaceAll(RegExp(r'<\/p>'), '<br>');
 
    parsedString = parsedString.replaceAll('<br>', '\n');

    // strip Html tags
    parsedString = parsedString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');

    //replace multiple break lines
    parsedString = parsedString.trim().replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
    
    return parsedString;
  }

  /// Access a character from [subject] at specified [position].
  ///
  /// If [position] is negative, `-1` refers to the last index, `-2` refers to the
  /// second last index and so on. If [position] is out of bound or [subject] is
  /// null, an empty string will be returned.
  ///
  /// Example:
  /// ```dart
  /// expect(charAt('Dart', 0), 'D');
  /// expect(charAt('Dart', -1), 't');
  /// expect(charAt('Dart', 5), '');
  /// ```
  ///
  static String charAt(String? subject, [int? positionP]) {
    var position = positionP == null ? 0 : positionP;
    if (subject is! String ||
        subject.length <= position ||
        subject.length + position < 0) {
      return '';
    }
    int _realPosition = position < 0 ? subject.length + position : position;
    return subject[_realPosition];
  }

  /// Converts the first character of [subject] to upper case.
  ///
  /// If [lowerRest] is set to true, the rest of the string will be converted to lower case.
  ///
  /// Example:
  /// ```dart
  /// capitalize("dartLang") // will return "DartLang"
  /// capitalize("dartLang", true) // will return "Dartlang"
  /// ```
  ///
  static String capitalize(String? subject, [bool lowerRest = false]) {
    if (subject is! String || subject.length == 0) {
      return '';
    }

    if (lowerRest) {
      return subject[0].toUpperCase() + subject.substring(1).toLowerCase();
    } else {
      return subject[0].toUpperCase() + subject.substring(1);
    }
  }

  /// Converts the first character of [subject] to lower case.
  ///
  /// Example:
  /// ```dart
  /// decapitalize("DartLang") // will return "dartLang"
  /// ```
  ///
  static String decapitalize(String? subject) {
    if (subject is! String || subject.length == 0) {
      return '';
    }

    return subject[0].toLowerCase() + subject.substring(1);
  }

  /// Converts all characters of [subject] to lower case.
  ///
  /// Example:
  /// ```dart
  /// lowerCase("dartLang") // will return "dartlang"
  /// ```
  ///
  static String lowerCase(String? subject) {
    if (subject is! String || subject.length == 0) {
      return '';
    }

    return subject.toLowerCase();
  }

  /// Splits the [subject] into a list of words.
  ///
  /// Example:
  /// ```dart
  /// split("dartLang") // will return ["dart", "Lang"]
  /// split("dart lang") // will return ["dart", "lang"]
  /// ```
  ///
  static List<String?> words(String? subject,
      [Pattern customPattern = defaultPattern]) {
    if (subject is! String || subject.length == 0) {
      return [];
    }

    late RegExp pattern;

    if (customPattern is String) {
      pattern = RegExp(customPattern);
    } else if (customPattern is RegExp) {
      pattern = customPattern;
    }

    return pattern.allMatches(subject).map((m) => m.group(0)).toList();
  }

  /// Converts all characters of [subject] to kebab case, aka *spinal case* or *lisp case*.
  ///
  /// Example:
  /// ```dart
  /// kebabCase("dart Lang") // will return "dart-lang"
  /// ```
  ///
  static String kebabCase(String subject) {
    var _splittedString = words(subject);

    if (_splittedString.length == 0) {
      return '';
    }

    return _splittedString.map(lowerCase).toList().join('-');
  }

  /// Converts all characters of [subject] to snake case.
  ///
  /// Example:
  /// ```dart
  /// snakeCase("dart Lang") // will return "dart_lang"
  /// ```
  ///
  static String snakeCase(String? subject) {
    var _splittedString = words(subject);

    if (_splittedString.length == 0) {
      return '';
    }

    return _splittedString.map(lowerCase).toList().join('_');
  }

  /// Converts all lower case characters of [subject] to upper case and all upper case characters to lower case.
  ///
  /// Example:
  /// ```dart
  /// swapCase("dartLang") // will return "DARTlANG"
  /// ```
  ///
  static String swapCase(String? subject) {
    if (subject is! String || subject.length == 0) {
      return '';
    }

    List<String> subjectChars = subject.split('');

    return subjectChars.map((x) => _swap(x)).join();
  }

  static String _swap(String char) {
    // so that characters that don't have the concept of cases will not be altered.
    String lowerCase = char.toLowerCase();
    String upperCase = char.toUpperCase();
    return char == lowerCase ? upperCase : lowerCase;
  }

  /// Converts all characters of [subject] to title case.
  ///
  /// Optional [notSplitList] specifies a list of characters which will be excluded as word separators.
  ///
  /// Example:
  /// ```dart
  /// titleCase("dart lang") // will return "Dart Lang"
  /// titleCase("jean-luc is good-looking", ["-"]) // will return "Jean-luc Is Good-looking"
  /// titleCase("jean-luc is good-looking") // will return "Jean-Luc Is Good-Looking"
  /// ```
  ///
  static String titleCase(String? subject,
      [List<String> notSplitList = const []]) {
    if (subject is! String || subject.length == 0) {
      return '';
    }

    RegExp _wordPattern = RegExp(WORD);

    int index = 0;

    String replacer(Match m) {
      var subString = m[0]!;
      index = subject.indexOf(subString, index);
      int previousIndex = index - 1;
      if (previousIndex >= 0 &&
          notSplitList.indexOf(subject[previousIndex]) >= 0) {
        index += subString.length;
        return lowerCase(subString);
      } else {
        index += subString.length;
        return capitalize(subString, true);
      }
    }

    return subject.replaceAllMapped(_wordPattern, replacer);
  }

  /// Converts all characters of [subject] to upper case.
  ///
  /// Example:
  /// ```dart
  /// upperCase("dartLang") // will return "DARTLANG"
  /// ```
  ///
  String upperCase(String? subject) {
    if (subject is! String || subject.length == 0) {
      return '';
    }

    return subject.toUpperCase();
  }

  /// Converts all characters of [subject] to camel case.
  ///
  /// Example:
  /// ```dart
  /// camelCase("dart lang") // will return "dartLang"
  /// ```
  ///
  static String camelCase(String subject) {
    var _splittedString = words(subject);
    if (_splittedString.length == 0) {
      return '';
    }
    var _firstWord = lowerCase(_splittedString[0]);
    var _restWords =
        _splittedString.sublist(1).map((x) => capitalize(x, true)).toList();
    return _firstWord + _restWords.join('');
  }

  static String slugify(String value, String separator) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'''[^a-z0-9\-_]'''), ' ')
        .trim()
        .replaceAll(RegExp(r'''[\-_\s]+'''), separator);
  }

  static String toPascalCase(String value) {
    return value
        .split(RegExp(r'''[\-_\s]+'''))
        .where((word) => word != '')
        .map((word) {
      return toSentenceCase(word);
    }).join('');
  }

  static String toSentenceCase(String value) {
    return toUpperCase(charAt(value)) + toLowerCase(value.substring(1));
  }

  static toUpperCase(String value) {
    return value.toUpperCase();
  }

  static String toLowerCase(String value) {
    return value.toLowerCase();
  }
}
