import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/db/db_connect.dart';
import 'package:esic_backend/src/modules/extra/repositories/extra_repository.dart';

import 'package:esic_core/esic_core.dart';

import 'package:esic_backend/src/shared/extensions/response_context_extensions.dart';

class ExtraController {
  static Future<dynamic> getAllTipoTelefone(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page =
          await ExtraRepository(esicDb).getAllTipoTelefone(filtros: filtros);
      return res.responsePage(page);
    } catch (e, s) {
      print('ExtraController@getAllTipoTelefone $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllFaixaEtaria(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page =
          await ExtraRepository(esicDb).getAllFaixaEtaria(filtros: filtros);

      return res.responsePage(page);
    } catch (e, s) {
      print('ExtraController@getAllFaixaEtaria $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllEscolaridade(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page =
          await ExtraRepository(esicDb).getAllEscolaridade(filtros: filtros);
      return res.responsePage(page);
    } catch (e, s) {
      print('ExtraController@getAllEscolaridade $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllPaises(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page = await ExtraRepository(esicDb).getAllPaises(filtros: filtros);

      return res.responsePage(page);
    } catch (e, s) {
      print('ExtraController@getAllPaises $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllEstados(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page = await ExtraRepository(esicDb).getAllEstados(filtros: filtros);
      return res.responsePage(page);
    } catch (e, s) {
      print('ExtraController@getAllEstados $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllMunicipios(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page =
          await ExtraRepository(esicDb).getAllMunicipios(filtros: filtros);
      return res.responsePage(page);
    } catch (e, s) {
      print('ExtraController@getAllMunicipios $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllTiposLogradouro(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page =
          await ExtraRepository(esicDb).getAllTiposLogradouro(filtros: filtros);

      return res.responsePage(page);
    } catch (e, s) {
      print('ExtraController@getAllTiposLograduro $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllCargos(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);
      var page = await ExtraRepository(esicDb).getAllCargos(filtros: filtros);

      return res.responsePage(page);
    } catch (e, s) {
      print('ExtraController@getAllCargos $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
