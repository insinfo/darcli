import 'dart:convert';

import 'package:rava_backend/rava_backend.dart';
import 'package:shelf/shelf.dart';

extension RequestExtension on Request {
  Future<Map<String, dynamic>> bodyAsMap() async {
    final requestBody = await readAsString();
    final requestData = json.decode(requestBody);
    return requestData;
  }
  /// retorno o token da Jubarte
  TokenData? get token {
    final map = context['tokenData'];
    if (map == null) {
      return null;
    }
    return TokenData.fromMap(map as Map<String, dynamic>);
  }

  Future<List> bodyAsList() async {
    final requestBody = await readAsString();
    final requestData = json.decode(requestBody);
    return requestData ?? [];
  }
}
