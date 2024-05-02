import 'dart:convert';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_core/esic_core.dart';

extension RequestContextExtensions on RequestContext {
  /// obtem o campo 'data' de um FormData decodificado como JSON
  Future<Map<String, dynamic>> getDataFieldFromFormData() async {
    Map<String, dynamic> payload = this.bodyAsMap;
    if (payload.containsKey('data') == false) {
      throw AngelHttpException.badRequest(
          message: "FormData não contem o field 'data'");
    }

    final data = jsonDecode(payload['data'].toString());
    return data as Map<String, dynamic>;
  }

  /// Obtem a instancia do model Token 
  AuthTokenJubarte get authToken {
    return container!.findByName<AuthTokenJubarte>('token');
  }

  int? getParamId() => int.tryParse(params['id'].toString());
}
