import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class ComplementoPessoaFisicaController {
  static Future<dynamic> getAll(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<ComplementoPessoaFisicaRepository>();
      final data = await repo.listar(filtros: req.filtros);
      return res.responseDataFrame(data);
    } catch (e, s) {
      print('ComplementoPessoaFisicaController@getAll $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future create(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<ComplementoPessoaFisicaRepository>();
      await repo
          .create(ComplementoPessoaFisica.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('ComplementoPessoaFisicaController@incluir $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future update(RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<ComplementoPessoaFisicaRepository>();
      await repo
          .update(ComplementoPessoaFisica.fromMap(await req.dataAsMap()));
      res.responseSuccess();
    } catch (e, s) {
      print('ComplementoPessoaFisicaController@alterar $e $s');
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
      final repo = req.container!.make<ComplementoPessoaFisicaRepository>();
      final items =
          data.map((e) => ComplementoPessoaFisica.fromMap(e)).toList();
      await repo.removeAllInTransaction(items);
      return res.responseSuccess();
    } catch (e, s) {
      print('ComplementoPessoaFisicaController@deleteAll $e $s');
      return res.responseError(StatusMessage.EXCLUDE_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
