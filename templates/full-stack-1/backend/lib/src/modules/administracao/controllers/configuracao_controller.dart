import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class ConfiguracaoController {
  ///
  static Future<dynamic> all(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      final filtros = Filters.fromMap(req.queryParameters);
      conn = await req.dbConnect();
      final page = await ConfiguracaoRepository(conn).all(filtros: filtros);
      await conn.disconnect();
      return res.responsePage(page);
    } catch (e, s) {
      await conn?.disconnect();
      print('ConfiguracaoController@all $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    } 
  }

  static Future<dynamic> getBy(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      conn = await req.dbConnect();
      final data = await ConfiguracaoRepository(conn)
          .getByModuloExercicioParametroAsMap(
              filtros.codModulo, filtros.anoExercicio, filtros.confParametro);
      await conn.disconnect();
      return res.responseJson(data);
    } catch (e, s) {
      await conn?.disconnect();
      print('ConfiguracaoController@getBy $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    } 
  }
}
