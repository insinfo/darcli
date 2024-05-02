import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/db/db_connect.dart';
import 'package:esic_backend/src/modules/usuario/repositories/usuario_repository.dart';

import 'package:esic_backend/src/shared/extensions/request_context_extensions.dart';
import 'package:esic_backend/src/shared/extensions/response_context_extensions.dart';
import 'package:esic_core/esic_core.dart';

class UsuarioController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page = await UsuarioRepository(esicDb).getAllAsMap(filtros: filtros);
      return res.responsePage(page);
    } catch (e, s) {
      print('UsuarioController@getAll $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    try {
      var item = await UsuarioRepository(esicDb).getById(req.getParamId()!);
      return res.responseJson(item);
    } catch (e, s) {
      print('UsuarioController@getById $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> insert(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();

      //final appConfig = req.container!.make<AppConfig>();
      //final token = req.container!.make<AuthTokenJubarte>();

      var item = Usuario.fromMap(req.bodyAsMap);

      await UsuarioRepository(esicDb).insert(item);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('UsuarioController@insert $e $s');
      return res.responseError(StatusMessage.ERROR_WHILE_WRITING_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> update(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var item = Usuario.fromMap(req.bodyAsMap);
      await UsuarioRepository(esicDb).update(item);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('UsuarioController@update $e $s');
      return res.responseError(StatusMessage.ERROR_WHEN_UPDATE_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> delete(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var item = Usuario.fromMap(req.bodyAsMap);
      await UsuarioRepository(esicDb).delete(item);
      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('UsuarioController@update $e $s');
      return res.responseError(StatusMessage.ERROR_WHEN_UPDATE_DATA,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> deleteAll(
      RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      var items = req.bodyAsList!.map((e) => Usuario.fromMap(e)).toList();
      await UsuarioRepository(esicDb).deleteAll(items);

      return res.responseJson(StatusMessage.seccessMap);
    } catch (e, s) {
      print('UsuarioController@update $e $s');
      return res.responseError(StatusMessage.ERROR_DELETING_DATA,
          exception: e, stackTrace: s);
    }
  }
}
