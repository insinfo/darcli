
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class EscolaridadeController {
  EscolaridadeController();

  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EscolaridadeRepository>();
      final data = await repo.getAll(filtros: req.filtros);

      return res.responseDataFrame(data);
    } catch (e, s) {
      print('EscolaridadeController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

   static Future<dynamic> getById(
      RequestContext req, ResponseContext res) async {
    final id = int.parse(req.params['id'].toString());

    try {
      final repo = req.container!.make<EscolaridadeRepository>();
      final data = await repo.getByIdAsMap(id);
      return res.responseJson(data);
    } catch (e, s) {
      print('EscolaridadeController@getById $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EscolaridadeRepository>();
      await repo
          .create(Escolaridade.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('EscolaridadeController@create $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EscolaridadeRepository>();
      await repo
          .update(Escolaridade.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('EscolaridadeController@update $e $s');
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
      final repo = req.container!.make<EscolaridadeRepository>();
      final items =
          data.map((e) => Escolaridade.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('EscolaridadeController@removeAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
