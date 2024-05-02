import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class VagaController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<VagaRepository>();
      final data = await repo.getAll(filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('VagaController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  /// lista todos os bloqueios de encaminhamento de uma vaga
  static Future<dynamic> getAllBloqueiosEncaminhamento(
      RequestContext req, ResponseContext res) async {
    try {
      final idVaga = int.tryParse(req.params['idVaga'].toString());

      if (idVaga == null) {
        throw Exception('idVaga tem que ser um inteiro valido');
      }

      final repo = req.container!.make<VagaRepository>();
      final data = await repo.getAllBloqueiosEncaminhamento(idVaga,
          filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('VagaController@getAllBloqueiosEncaminhamento $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllForSite(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<VagaRepository>();
      final data = await repo.getAllForSite(filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('VagaController@getAllForSite $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    final id = int.parse(req.params['id'].toString());

    try {
      final repo = req.container!.make<VagaRepository>();
      final data = await repo.getByIdAsMap(id);
      return res.responseJson(data);
    } catch (e, s) {
      print('VagaController@getById $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<VagaRepository>();
      await repo.createInTransaction(
          req.jubarteToken.idPessoa, Vaga.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('VagaController@create $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future bloquearVaga(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<VagaRepository>();

      final map = await req.dataAsMap();
      final bloqueioEncaminhamento = BloqueioEncaminhamento.fromMap(map);

      await repo.bloquearVagaInTransaction(
          req.jubarteToken.idPessoa, bloqueioEncaminhamento);

      res.responseSuccess();
    } catch (e, s) {
      print('VagaController@bloquearVaga $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future desbloquearVaga(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<VagaRepository>();

      final map = await req.dataAsMap();
      final bloqueioEncaminhamento = BloqueioEncaminhamento.fromMap(map);

      await repo.desbloquearVagaInTransaction(
          req.jubarteToken.idPessoa, bloqueioEncaminhamento);

      res.responseSuccess();
    } catch (e, s) {
      print('VagaController@desbloquearVaga $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getByIdFromWeb(
      RequestContext req, ResponseContext res) async {
    final id = int.parse(req.params['id'].toString());

    try {
      final repo = req.container!.make<VagaRepository>();
      final vaga = await repo.getById(id);

      if (req.sibemToken.idPessoa != vaga.idEmpregador) {
        return res.responseError(
          'Você não pode alterar uma vaga de outro empregador',
        );
      }

      return res.responseModel(vaga);
    } catch (e, s) {
      print('VagaController@getById $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future createFromWeb(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<VagaRepository>();
      final vaga = Vaga.fromMap(await req.dataAsMap());
      vaga.isFromWeb = true;
      await repo.createInTransaction(req.sibemToken.idPessoa!, vaga);
      res.responseSuccess();
    } catch (e, s) {
      print('VagaController@createFromWeb $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future updateFromWeb(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<VagaRepository>();
      final vaga = Vaga.fromMap(await req.dataAsMap());

      if (req.sibemToken.idPessoa != vaga.idEmpregador) {
        throw Exception('Você não pode alterar uma vaga de outro empregador');
      }
      await repo.updateInTransaction(req.sibemToken.idPessoa!, vaga);
      res.responseSuccess();
    } catch (e, s) {
      print('VagaController@updateFromWeb $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<VagaRepository>();
      final map = await req.dataAsMap();
      final vaga = Vaga.fromMap(map);
      await repo.updateInTransaction(req.jubarteToken.idPessoa, vaga);
      res.responseSuccess();
    } catch (e, s) {
      print('VagaController@update $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> validarVaga(
      RequestContext req, ResponseContext res) async {
    final idVaga = int.parse(req.params['id'].toString());

    try {
      final repo = req.container!.make<VagaRepository>();
      await repo.validarVaga(idVaga);
      return res.responseSuccess();
    } catch (e, s) {
      print('VagaController@validarVaga $e $s');
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
      final repo = req.container!.make<VagaRepository>();
      final items = data.map((e) => Vaga.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('VagaController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
