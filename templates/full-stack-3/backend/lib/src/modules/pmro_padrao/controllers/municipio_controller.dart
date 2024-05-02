import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class MunicipioController {
  MunicipioController();

  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<MunicipioRepository>();
      final data = await repo.getAll(filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('MunicipioController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllBySiglaUf(
      RequestContext req, ResponseContext res) async {
    try {
      final siglaUf = req.params['siglaUf'];
      final repo = req.container!.make<MunicipioRepository>();
      final page = await repo.getAllBySiglaUf(siglaUf);
      return res.responsePage(page);
    } catch (e, s) {
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<MunicipioRepository>();
      final id = int.tryParse(req.params['id'].toString());
      if (id == null) {
        throw Exception('id não pode ser nulo');
      }
      final page = await repo.getById(id);
      return res.responseModel(page);
    } catch (e, s) {
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> getAllByIdUf(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<MunicipioRepository>();
      final idUf = int.tryParse(req.params['idUf'].toString());
      if (idUf == null) {
        throw Exception('idUf não pode ser nulo');
      }
      final page = await repo.getAllByIdUf(idUf);
      return res.responsePage(page);
    } catch (e, s) {
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<MunicipioRepository>();
      await repo.create(Municipio.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('MunicipioController@create $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<MunicipioRepository>();
      await repo.update(Municipio.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('MunicipioController@update $e $s');
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
      final repo = req.container!.make<MunicipioRepository>();
      final items = data.map((e) => Municipio.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('MunicipioController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
