import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class BloqueioEncaminhamentoController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<BloqueioEncaminhamentoRepository>();
      final data = await repo.getAll(filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('BloqueioEncaminhamentoController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

   static Future<dynamic> getById(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<BloqueioEncaminhamentoRepository>();
      final data = await repo.getByIdAsMap(req.params['id']);
      return res.responseJson(data);
    } catch (e, s) {
      print('BloqueioEncaminhamentoController@getById $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<BloqueioEncaminhamentoRepository>();
      await repo.create(BloqueioEncaminhamento.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('BloqueioEncaminhamentoController@create $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<BloqueioEncaminhamentoRepository>();
      await repo.update(BloqueioEncaminhamento.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('BloqueioEncaminhamentoController@update $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
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
      final repo = req.container!.make<BloqueioEncaminhamentoRepository>();
      final items =
          data.map((e) => BloqueioEncaminhamento.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('BloqueioEncaminhamentoController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
