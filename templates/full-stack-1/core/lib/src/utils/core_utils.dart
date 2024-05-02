import 'package:intl/intl.dart';
import 'replacements.dart';
import 'package:http/http.dart' as http;

final _dupeSpaceRegExp = RegExp(r'\s{2,}');
final _punctuationRegExp = RegExp(r'[^\w\s-]');

class SaliCoreUtils {
  static String removeNonIso88591Characters(String input) {
    return input.replaceAll(RegExp(r'[^\x00-\xFF]'), '');
  }

  /// baixa/download um arquivo de texto
  static Future<String> getNetworkTextFile(String url,
      {Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return response.body;
  }

  /// oculta partes de um texto por exemplo CPF
  static String hidePartsOfString(String string,
      {int visibleCharacters = 2, String trail = '*'}) {
    if (string.length < visibleCharacters) {
      return string;
    }
    return string.substring(0, visibleCharacters) +
        (trail * (string.length - visibleCharacters));
  }

  /// Converts [text] to a slug [String] separated by the [delimiter].
  static String slugify(String text,
      {String delimiter = '-', bool lowercase = true}) {
    // Trim leading and trailing whitespace.
    var slug = text.trim();

    // Make the text lowercase (optional).
    if (lowercase) {
      slug = slug.toLowerCase();
    }

    // Substitute characters for their latin equivalent.
    replacements.forEach((k, v) => slug = slug.replaceAll(k, v));

    slug = slug
        // Condense whitespaces to 1 space.
        .replaceAll(_dupeSpaceRegExp, ' ')
        // Remove punctuation.
        .replaceAll(_punctuationRegExp, '')
        // Replace space with the delimiter.
        .replaceAll(' ', delimiter);

    return slug;
  }

  static dynamic customJsonEncode(dynamic item) {
    if (item is num) {
      return item;
    } else if (item is String) {
      return item;
    } else if (item is bool) {
      return item;
    } else if (item is DateTime) {
      return item.toIso8601String();
    } else {
      return item.toString();
    }
    //return item;
  }

  static bool isNotNullOrEmpty(value) {
    return value != null && value != 'null' && value != '';
  }

  static bool isNotNullOrEmptyAndContain(Map<String, dynamic> json, key) {
    return json.containsKey(key) && isNotNullOrEmpty(json[key]);
  }

  static String removerAcentos(String s) {
    var map = <String, String>{
      'â': 'a',
      'Â': 'A',
      'à': 'a',
      'À': 'A',
      'á': 'a',
      'Á': 'A',
      'ã': 'a',
      'Ã': 'A',
      'ê': 'e',
      'Ê': 'E',
      'è': 'e',
      'È': 'E',
      'é': 'e',
      'É': 'E',
      'î': 'i',
      'Î': 'I',
      'ì': 'i',
      'Ì': 'I',
      'í': 'i',
      'Í': 'I',
      'õ': 'o',
      'Õ': 'O',
      'ô': 'o',
      'Ô': 'O',
      'ò': 'o',
      'Ò': 'O',
      'ó': 'o',
      'Ó': 'O',
      'ü': 'u',
      'Ü': 'U',
      'û': 'u',
      'Û': 'U',
      'ú': 'u',
      'Ú': 'U',
      'ù': 'u',
      'Ù': 'U',
      'ç': 'c',
      'Ç': 'C'
    };
    var result = s;
    map.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }

  /// 28/12/2021 to => 2021-12-28
  static String? stringBrasilDateToIsoDate(String? strBDate) {
    if (strBDate == null) {
      return strBDate;
    }
    try {
      final date = DateFormat('dd/MM/yyyy').parse(strBDate.trim());
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return null;
    }
  }

  static String? isoDateToBrasilDateString(String? strBDate) {
    if (strBDate == null) {
      return strBDate;
    }
    try {
      final date = DateFormat('yyyy-MM-dd').parse(strBDate.trim());
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return null;
    }
  }

  static String dateToBrasilDateString(DateTime? date) {
    if (date == null) {
      return '';
    }
    try {
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  /// Divida a string em pedaços de tamanho máximo parando na quebra de linha
  /// https://stackoverflow.com/questions/72883396/split-string-into-chunks-of-max-size-stopping-at-line-break
  static List<String> slicesText(String text, {int length = 1023}) {
    var startIdx = 0;
    var endIdx = 0;
    final chunks = <String>[];
    var lyrics = text;

    if (!lyrics.endsWith('\n')) {
      lyrics = lyrics + '\n';
    }

    while (endIdx < lyrics.length) {
      endIdx = rfind(lyrics, '\n', startIdx, startIdx + length - 1) + 1;
      if (endIdx == 0) {
        endIdx = startIdx + length;
      }
      chunks.add(lyrics.substring(startIdx, endIdx));
      startIdx = endIdx;
    }

    return chunks;
  }

  /// dart implementation of python rfind
  static int rfind(String text, String subString, int startIdx, int endIdx) {
    if (startIdx < 0) startIdx = 0;

    if (endIdx >= text.length) endIdx = text.length - 1;

    for (var i = endIdx; i >= startIdx; i--) {
      if (text.substring(i, i + subString.length) == subString) {
        return i;
      }
    }

    return -1;
  }

  
}
