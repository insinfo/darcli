import 'dart:convert';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

/// Insere uma funcionalidade ao header da requisição para não precisar repetir a formatação do cabeçalho.
extension ResponseJson on RequestContext {
  /// Obtem a instancia do model JubarteToken que são os dados de autenticação da jubarte
  JubarteToken get jubarteToken {
    final tokenData = container!.make<JubarteToken>();
    return tokenData;
  }

  AuthPayload get sibemToken {
    final tokenData = container!.make<AuthPayload>();
    return tokenData;
  }

  /// obtem os filtros vindo na URL
  Filters get filtros => Filters.fromMap(queryParameters);

  Future<Map<String, dynamic>> dataAsMap() async {
    await parseBody();
    final Map<String, dynamic> dados = bodyAsMap;
    return dados;
  }

  Future<List<dynamic>> dataAsList() async {
    await parseBody();
    final dados = bodyAsList;
    return dados ?? [];
  }

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

  /// obtem a conexão com o bamco de dados
  /// `Return` package:eloquent/src/connection.dart
  Connection get db {
    final connection = container!.make<Connection>();
    return connection;
  }

  // Future<Connection> dbConnect([String? name]) {
  //   return DBLayer().connect(name);
  // }

  int? getParamId() => int.tryParse(params['id'].toString());
}
