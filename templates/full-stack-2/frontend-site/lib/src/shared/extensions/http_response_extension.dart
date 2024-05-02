import 'dart:convert';

import 'package:http/http.dart' as http;

extension BodyUtf8Extension on http.Response {
  /// retorna a string de texto retornada pelo servidor HTTP decodificando em UTF8
  String get bodyUtf8 => utf8.decode(bodyBytes);
}
