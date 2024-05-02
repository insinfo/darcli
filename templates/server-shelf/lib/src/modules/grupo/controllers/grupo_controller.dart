import 'package:eloquent/eloquent.dart';
import 'package:rava_backend/rava_backend.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class GrupoController {
  static Future<Response> all(Request req) async {
    Connection? conn;
    try {
      conn = await DBLayer().connect();
      //await req.bodyAsMap()
      final filtros = Filters.fromMap(req.url.queryParameters);
      final repo = GrupoRepository(conn);
      final data = await repo.all(filtros: filtros);
      await conn.disconnect();
      return responseDataFrame(data);
    } catch (e, s) {
      await conn?.disconnect();
      print('GrupoController@all $e $s');
      return responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<Response> getByNumero(Request req) async {
    Connection? conn;
    try {
      conn = await DBLayer().connect();
      final id = int.tryParse(req.params['id'].toString());
      if (id == null) {
        throw Exception('O parametro id tem que ser um número inteiro valido');
      }
      final repo = GrupoRepository(conn);
      final item = await repo.getByNumero(id);
      await conn.disconnect();
      return responseModel(item);
    } catch (e, s) {
      await conn?.disconnect();
      print('GrupoController@getByNumero $e $s');
      return responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<Response> insert(Request req) async {
    Connection? conn;
    try {
      conn = await DBLayer().connect();
      //
      final item = Grupo.fromMap(await req.bodyAsMap());

      final repo = GrupoRepository(conn);
      await repo.insert(item);

      // grava na auditoria
      await auditoriaService.acaoInserir('Grupo ${item.numero}', req);

      await conn.disconnect();
      return responseModel(item);
    } catch (e, s) {
      await conn?.disconnect();
      print('GrupoController@insert $e $s');
      return responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<Response> update(Request req) async {
    Connection? conn;
    try {
      conn = await DBLayer().connect();

      final id = int.tryParse(req.params['id'].toString());
      if (id == null) {
        throw Exception('O parametro id tem que ser um número inteiro valido');
      }

      final item = Grupo.fromMap(await req.bodyAsMap());

      final repo = GrupoRepository(conn);
      await repo.update(item);

      // grava na auditoria
      await auditoriaService.acaoAtualizar('Grupo ${item.numero}', req);

      await conn.disconnect();
      return responseModel(item);
    } catch (e, s) {
      await conn?.disconnect();
      print('GrupoController@update $e $s');
      return responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<Response> deleteAll(Request req) async {
    Connection? conn;
    try {
      conn = await DBLayer().connect();
      final data = await req.bodyAsList();

      final items = data.map((e) => Grupo.fromMap(e)).toList();
      final repo = GrupoRepository(conn);
      await repo.deleteAll(items);

      // grava na auditoria
      await auditoriaService.acaoRemover(
          'Grupo ${items.map((e) => e.numero).join(', ')}', req);

      await conn.disconnect();
      return responseSuccess();
    } catch (e, s) {
      await conn?.disconnect();
      print('GrupoController@deleteAll $e $s');
      return responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
