import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class CandidatoController {
  /// lista candidatos
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CandidatoRepository>();
      final data = await repo.getAll(filtros: req.filtros);
      return res.responseDataFrame(data);
    } catch (e, s) {
      print('CandidatoController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  /// lista candidatos encaminhados para um empregador
  static Future<dynamic> getAllByEmpregador(
      RequestContext req, ResponseContext res) async {
    try {
      final idEmpregador = int.tryParse(req.params['idEmpregador'].toString());

      if (idEmpregador == null) {
        throw Exception('idEmpregador não pode ser nulo');
      }

      final repo = req.container!.make<CandidatoRepository>();

      final filtros = req.filtros;
      filtros.idEmpregador = req.sibemToken.idPessoa!;

      final data = await repo.getAll(filtros: filtros);
      return res.responseDataFrame(data);
    } catch (e, s) {
      print('CandidatoController@getAllByEmpregador $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  /// obtem um  Candidato pelo idCandidato
  static Future<dynamic> getByIdCandidato(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CandidatoRepository>();
      final idCandidato = int.tryParse(req.params['id'].toString());
      if (idCandidato == null) {
        throw Exception(
            'CandidatoController@getById idCandidato não pode ser nulo');
      }

      //print('CandidatoController@getById idCandidato $idCandidato  ');

      final data = await repo.getByIdCandidatoAsMap(idCandidato);
      if (data == null) {
        return res.responseNotFound(
            message: 'Não foi possível localizar este Candidato');
      }

      return res.responseJson(data);
    } catch (e, s) {
      print('CandidatoController@getById $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getByCpf(
      RequestContext req, ResponseContext res) async {
    final cpf = req.params['cpf'].toString();

    try {
      final repo = req.container!.make<CandidatoRepository>();
      final data = await repo.getByCpf(cpf);
      return res.responseJson(data);
    } catch (e, s) {
      print('CandidatoController@getByCpf $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CandidatoRepository>();
      final data = await req.dataAsMap();
      final candidato = Candidato.fromMap(data);
      await repo.createInTransaction(req.jubarteToken.idPessoa, candidato);
      res.responseSuccess();
    } catch (e, s) {
      print('CandidatoController@create $e $s');
      return res.responseError(StatusMessage.INSERT_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<CandidatoRepository>();
      await repo.updateInTransaction(
          req.jubarteToken.idPessoa, Candidato.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('CandidatoController@update $e $s');
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
      final repo = req.container!.make<CandidatoRepository>();
      final items = data.map((e) => Candidato.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('CandidatoController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
