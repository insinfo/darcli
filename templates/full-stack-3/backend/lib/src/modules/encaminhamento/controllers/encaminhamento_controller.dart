import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class EncaminhamentoController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EncaminhamentoRepository>();
      final data = await repo.getAll(filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('EncaminhamentoController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  /// lista candidatos encaminhados para um empregador
  static Future<dynamic> getAllByEmpregadorForWeb(
      RequestContext req, ResponseContext res) async {
    try {
      var idEmpregador = int.tryParse(req.params['idEmpregador'].toString());

      if (idEmpregador == null) {
        throw Exception('idEmpregador não pode ser nulo');
      }

      final repo = req.container!.make<EncaminhamentoRepository>();

      // final filtros = req.filtros;
      // filtros.idEmpregador = req.sibemToken.idPessoa!;
      idEmpregador = req.sibemToken.idPessoa!;

      final data =
          await repo.getAllByEmpregador(idEmpregador, filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('EncaminhamentoController@getAllByEmpregador $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    final id = int.parse(req.params['id'].toString());

    try {
      final repo = req.container!.make<EncaminhamentoRepository>();
      final data = await repo.getByIdAsMap(id);
      return res.responseJson(data);
    } catch (e, s) {
      print('EncaminhamentoController@getById $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EncaminhamentoRepository>();
      await repo.createInTransaction(req.jubarteToken.idPessoa,
          Encaminhamento.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('EncaminhamentoController@create $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future updateStatus(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EncaminhamentoRepository>();
      final data = await req.dataAsMap();
      final encaminhamento = Encaminhamento.fromMap(data);

      await repo.updateStatus(req.jubarteToken.idPessoa, encaminhamento);

      res.responseSuccess();
    } catch (e, s) {
      print('EncaminhamentoController@atualizarStatus $e $s');
      return res.responseError(StatusMessage.UPDATE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future updateStatusForWeb(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EncaminhamentoRepository>();
      final data = await req.dataAsMap();
      final encaminhamento = Encaminhamento.fromMap(data);

      await repo.updateStatus(req.sibemToken.idPessoa, encaminhamento);

      res.responseSuccess();
    } catch (e, s) {
      print('EncaminhamentoController@updateStatusForWeb $e $s');
      return res.responseError(StatusMessage.UPDATE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EncaminhamentoRepository>();
      await repo.update(Encaminhamento.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('EncaminhamentoController@update $e $s');
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
      final repo = req.container!.make<EncaminhamentoRepository>();
      await repo.removeByIdInTransaction(id);
      return res.responseSuccess();
    } catch (e, s) {
      print('EncaminhamentoController@remove $e $s');
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
      final repo = req.container!.make<EncaminhamentoRepository>();
      final items = data.map((e) => Encaminhamento.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('EncaminhamentoController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
