import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

Matcher isEquals(expectVal) {
  return predicate((dynamic value) {
    print('isEquals value: $value == $expectVal');
    return value == expectVal;
  }, 'is Equals');
}


extension UriExtension on Uri {
  Uri addQueryParameters(Map<String, dynamic> queryParameters) {
    final url = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: path,
      query: query,
      queryParameters: queryParameters,
      fragment: fragment,
      userInfo: userInfo,
    );
    return url;
  }
}

extension ResponseExtension on http.Response {
  /// usa jsonDecode e Utf8Decoder e retorna os dados como um map (use somente se o backend for retornar um json)
  Map<String, dynamic> bodyAsMap() {
    return jsonDecode(Utf8Decoder().convert(bodyBytes));
  }
  /// usa jsonDecode e Utf8Decoder e retorna os dados como um List (use somente se o backend for retornar um array [])
  List bodyAsList() {
    return jsonDecode(Utf8Decoder().convert(bodyBytes));
  }
}
