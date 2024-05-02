import 'dart:convert';

import 'package:http/http.dart' as http;

/// retorna a string de texto retornada pelo servidor HTTP decodificando em UTF8
extension BodyUtf8Extension on http.Response {
  /// retorna a string de texto retornada pelo servidor HTTP decodificando em UTF8
  String get bodyUtf8 => utf8.decode(bodyBytes);

  /// body as Map
  Map<String, dynamic>? get bodyAsMap {
    final data = jsonDecode(bodyUtf8);
    if (data is Map) {
      return data as Map<String, dynamic>;
    }
    return null;
  }

  /// body as List of Map
  List<Map<String, dynamic>> get bodyAsListMap {
    final data = jsonDecode(bodyUtf8);
    if (data is List) {
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return <Map<String, dynamic>>[];
  }
}
