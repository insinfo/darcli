import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/rest_config.dart';
import 'package:new_sali_frontend/src/shared/services/rest_service_base.dart';

class EstatisticaService extends RestServiceBase {
  EstatisticaService(RestConfig conf) : super(conf);
  String path = '/estatistica';

  /// total de processos por periodo e setor destino do primero tramite
  Future<List<Map<String, dynamic>>> processByPeriodoSetorPrimeroTramite(
      [Filters? filtros]) {
    return getListMap('$path/processos/periodo/setor/primero/tramite',
        filtros: filtros);
  }

  /// lista o total de Processos por ano desde 20 anos atras a partir do ano atual
  Future<List<Map<String, dynamic>>> totalProcessosPorAno([Filters? filtros]) {
    return getListMap('$path/processos/ano', filtros: filtros);
  }

  Future<List<Map<String, dynamic>>> processosPorSituacao([Filters? filtros]) {
    return getListMap('$path/processos/situacao', filtros: filtros);
  }

  Future<List<Map<String, dynamic>>> processosPorClassificacao(
      [Filters? filtros]) {
    return getListMap('$path/processos/classificacao', filtros: filtros);
  }

  Future<List<Map<String, dynamic>>> totalProcessosPorAssunto(
      [Filters? filtros]) {
    return getListMap('$path/processos/assunto', filtros: filtros);
  }
}
