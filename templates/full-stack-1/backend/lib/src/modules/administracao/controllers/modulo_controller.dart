import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class ModuloController {
  /// lista todos os modulos
  static Future<dynamic> all(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      final filtros = Filters.fromMap(req.queryParameters);
      conn = await req.dbConnect();
      final page = await ModuloRepository(conn).all(filtros: filtros);
      await conn.disconnect();
      return res.responsePage(page);
    } catch (e, s) {
      await conn?.disconnect();
      print('ModuloController@all $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> insert(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      // abre a conexão
      conn = await req.dbConnect();

      final repo = ModuloRepository(conn);
      final item = Modulo.fromMap(req.bodyAsMap);

      await conn.transaction((ctx) async {
        // cadastra
        await repo.insert(item, connection: ctx);
      });

      // fecha a conexão
      await conn.disconnect();
      //limpa o cache
      //await DiskMapCache.clearByName(cacheName, AppConfig.inst().appCacheDir);

      return res.responseModel(item);
    } catch (e, s) {
      await conn?.disconnect();
      print('ModuloController@insert $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> update(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();

      conn = await req.dbConnect();
      final repo = ModuloRepository(conn);
      final item = Modulo.fromMap(req.bodyAsMap);
      await conn.transaction((ctx) async {
        // atualiza
        await repo.update(item, connection: ctx);
      });

      await conn.disconnect();

      return res.responseModel(item);
    } catch (e, s) {
      await conn?.disconnect();
      print('ModuloController@update $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> deleteAll(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();

      final items = req.bodyAsList!
          .map((e) => Modulo.fromMap(e as Map<String, dynamic>))
          .toList();

      conn = await req.dbConnect();

      final repo = ModuloRepository(conn);

      for (var item in items) {
        await conn.transaction((ctx) async {
          await repo.delete(
            item,
            connection: ctx,
          );
        });
      }
      await conn.disconnect();

      return res.responseSuccess();
    } catch (e, s) {
      await conn?.disconnect();
      print('ModuloController@deleteAll $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
