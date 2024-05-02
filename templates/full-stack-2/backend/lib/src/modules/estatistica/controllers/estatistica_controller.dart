import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_backend/src/db/db_connect.dart';
import 'package:esic_backend/src/modules/estatistica/repositories/estatistica_repository.dart';

import 'package:esic_backend/src/shared/extensions/response_context_extensions.dart';
import 'package:esic_core/esic_core.dart';

class EstatisticaController {
  ///  quantidade de pedidos de informação e respostas registrados no e-SIC Livre por ano
  static Future<dynamic> solicitacoesPorAno(
      RequestContext req, ResponseContext res) async {
    try {
      var filtros = Filters.fromMap(req.queryParameters);

      var page = await EstatisticaRepository(esicDb)
          .solicitacoesPorAno(filtros: filtros);

      return res.responsePage(page);
    } catch (e, s) {
      print('EstatisticaController@solicitacoesPorAno $e $s');
      return res.responseError(StatusMessage.ERROR_GENERIC,
          exception: e, stackTrace: s);
    }
  }
}
