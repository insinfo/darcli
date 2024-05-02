import 'dart:convert';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/src/db/db_layer.dart';
import 'package:new_sali_core/new_sali_core.dart';

extension RequestContextExtensions on RequestContext {
  /// obtem o campo 'data' de um FormData decodificado como JSON
  Map<String, dynamic> getDataFieldFromFormData() {
    Map<String, dynamic> payload = this.bodyAsMap;
    if (payload.containsKey('data') == false) {
      throw AngelHttpException.badRequest(
          message: "FormData não contem o field 'data'");
    }

    final data = jsonDecode(payload['data'].toString());
    return data as Map<String, dynamic>;
  }

  /// Obtem a instancia do model AuthPayload que são os dados de autenticação
  AuthPayload get authToken {
    final tokenData = container!.make<AuthPayload>();
    return tokenData;
  }

  /// obtem a conexão com o bamco de dados
  /// `Return` package:eloquent/src/connection.dart
  // Connection get db{
  //    final connection = container!.make<Connection>();
  //   return connection;
  // }

  Future<Connection> dbConnect([String? name]) {
    return DBLayer().connect(name);
  }

  int? getParamId() => int.tryParse(params['id'].toString());
}
