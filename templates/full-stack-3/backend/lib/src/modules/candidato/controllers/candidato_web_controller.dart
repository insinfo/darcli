import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class CandidatoWebController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CandidatoWebRepository>();
      final data = await repo.getAll(filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('CandidatoWebController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CandidatoWebRepository>();
      final data = await repo.getByIdAsMap(req.params['id']);
      return res.responseJson(data);
    } catch (e, s) {
      print('CandidatoWebController@getById $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getByCpf(
      RequestContext req, ResponseContext res) async {
    final cpf = req.params['cpf'].toString();
    try {
      final repo = req.container!.make<CandidatoWebRepository>();
      final data = await repo.getByCpfAsMap(cpf);
      return res.responseJson(data);
    } on NotFoundException {
      return res.responseNotFound();
    } catch (e, s) {
      print('CandidatoController@getByCpf $e $s');
      return res.responseError(StatusMessage.UNABLE_TO_OBTAIN_THIS_RECORD,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CandidatoWebRepository>();
      final map = await req.dataAsMap();
      final cand = CandidatoWeb.fromMap(map);
      await repo.create(cand);
      res.responseSuccess();
    } catch (e, s) {
      print('CandidatoWebController@create $e $s');
      return res.responseError(StatusMessage.INSERT_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CandidatoWebRepository>();
      await repo.update(CandidatoWeb.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('CandidatoWebController@update $e $s');
      return res.responseError(StatusMessage.UPDATE_ERROR_MESSAGE,
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
      final repo = req.container!.make<CandidatoWebRepository>();
      final items = data.map((e) => CandidatoWeb.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('CandidatoWebController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
