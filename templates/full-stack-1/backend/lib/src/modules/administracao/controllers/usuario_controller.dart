import 'package:angel3_framework/angel3_framework.dart';
import 'package:eloquent/eloquent.dart';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';

class UsuarioController {
  /// lista todos os usuarios
  static Future<dynamic> all(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      final filtros = Filters.fromMap(req.queryParameters);
      conn = await req.dbConnect();
      final page = await UsuarioRepository(conn).all(filtros: filtros);
      await conn.disconnect();
      return res.responsePage(page);
    } catch (e, s) {
      await conn?.disconnect();
      print('UsuarioController@all $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> byNumCgm(
      RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      final numCgm = int.parse(req.params['numcgm']);
      conn = await req.dbConnect();
      final model = await UsuarioRepository(conn).byNumCgm(numCgm);
      await conn.disconnect();
      return res.responseModel(model);
    } catch (e, s) {
      await conn?.disconnect();
      print('UsuarioController@byNumCgm $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> insert(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      final usuario = Usuario.fromMap(req.bodyAsMap);

      conn = await req.dbConnect();

      final user = await conn.transaction((ctx) async {
        return await UsuarioRepository(ctx).insert(usuario, connection: ctx);
      });

      await AuditoriaRepository(conn).insert(
        Auditoria(
          numCgm: req.authToken.numCgm,
          codAcao: 27,
          timestamp: DateTime.now(),
          objeto: 'numcgm = ${user.numCgm}',
          transacao: true,
        ),
      );

      await conn.disconnect();

      return res.responseModel(user as Usuario);
    } catch (e, s) {
      await conn?.disconnect();
      print('UsuarioController@insert $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> update(RequestContext req, ResponseContext res) async {
    Connection? conn;
    try {
      await req.parseBody();
      final usuario = Usuario.fromMap(req.bodyAsMap);
      conn = await req.dbConnect();
      final model = await conn.transaction((ctx) async {
        final m = await UsuarioRepository(ctx).update(usuario, connection: ctx);
        return m;
      });

      await AuditoriaRepository(conn).insert(
        Auditoria(
          numCgm: req.authToken.numCgm,
          codAcao: 23,
          timestamp: DateTime.now(),
          objeto: 'numcgm = ${usuario.numCgm}',
          transacao: true,
        ),
      );

      await conn.disconnect();

      return res.responseModel(model as Usuario);
    } catch (e, s) {
      await conn?.disconnect();
      print('UsuarioController@update $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
