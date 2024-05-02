import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class PessoaJuridicaController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<PessoaJuridicaRepository>();
      final data = await repo.getAll(filtros: req.filtros);
      return res.responseDataFrame(data);
    } catch (e, s) {
      print('PessoaJuridicaController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      var idUsuarioLogado = 9663;
      print(
          'PessoaJuridicaController@create idUsuarioLogado $idUsuarioLogado alterar isso');
      final repo = req.container!.make<PessoaJuridicaRepository>();
      await repo.createInTransaction(
          idUsuarioLogado, PessoaJuridica.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('PessoaJuridicaController@create $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      var idUsuarioLogado = 9663;
      print(
          'PessoaJuridicaController@update idUsuarioLogado $idUsuarioLogado alterar isso');

      final repo = req.container!.make<PessoaJuridicaRepository>();
      await repo.alterarInTransaction(
          idUsuarioLogado, PessoaJuridica.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('PessoaJuridicaController@update $e $s');
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
      final repo = req.container!.make<PessoaJuridicaRepository>();
      final items = data.map((e) => PessoaJuridica.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('PessoaJuridicaController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
