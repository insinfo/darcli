import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class AuditoriaController {
  /// lista todas as entradas da tabela de auditoria para o frontend
  static Future<dynamic> all(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      final filtros = Filters.fromMap(req.queryParameters);
      conn = await req.dbConnect();
      final page = await AuditoriaRepository(conn).all(filtros: filtros);
      await conn.disconnect();
      return res.responsePage(page);
    } catch (e, s) {
      await conn?.disconnect();
      print('AuditoriaController@all $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    } 
  }

  /// cria uma nova linha na tabela de auditoria
  static Future<dynamic> create(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      conn = await req.dbConnect();
      final auditoria = Auditoria.fromMap(req.bodyAsMap);
      await AuditoriaRepository(conn).insert(auditoria);
      await conn.disconnect();
      return res.responseSuccess();
    } catch (e, s) {
      await conn?.disconnect();
      print('AuditoriaController@create $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    } 
  }
}
