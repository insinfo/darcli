import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class CursoController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CursoRepository>();
      final data = await repo.getAll(filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('CursoController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future importXlsx(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final files = req.uploadedFiles;
      if (files == null) {
        throw Exception('Nenhum arquivo passado');
      }
      if (files.isEmpty) {
        throw Exception('Nenhum arquivo passado');
      }

      final repo = req.container!.make<CursoRepository>();
      final bytes = await files.first.readAsBytes();
      await repo.importXlsx(bytes);

      res.responseSuccess();
    } catch (e, s) {
      print('CursoController@create $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    final id = int.parse(req.params['id'].toString());

    try {
      final repo = req.container!.make<CursoRepository>();
      final data = await repo.getByIdAsMap(id);
      return res.responseJson(data);
    } catch (e, s) {
      print('CursoController@getById $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CursoRepository>();
      await repo.create(Curso.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('CursoController@create $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CursoRepository>();
      await repo.update(Curso.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('CursoController@update $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future remove(RequestContext req, ResponseContext res) async {
    try {
      final id = int.tryParse(req.params['id'].toString());
      if (id == null) {
        throw Exception('O parametro id tem que ser um número inteiro valido');
      }
      final repo = req.container!.make<CursoRepository>();

      await repo.removeByIdInTransaction(id);
      return res.responseSuccess();
    } catch (e, s) {
      print('CursoController@remove $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future removeAll(RequestContext req, ResponseContext res) async {
    try {
      final data = await req.dataAsList();
      // final id = int.tryParse(req.params['id'].toString());
      // if (id == null) {
      //   throw Exception('O parametro id tem que ser um número inteiro valido');
      // }
      final repo = req.container!.make<CursoRepository>();
      final items = data.map((e) => Curso.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('CursoController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
