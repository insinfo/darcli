import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend_site/src/shared/rest_config.dart';
import 'package:esic_frontend_site/src/shared/services/rest_service_base.dart';

class EstatisticaService extends RestServiceBase {
  EstatisticaService(RestConfig conf) : super(conf);
  String path = '/estatisticas';

  Future<DataFrame<EstatisticaSolicitacao>> solicitacoesPorAno(
      Filters filtros) {
    return getDataFrame<EstatisticaSolicitacao>(
        '$path/solicitacoes/ano', (m) => EstatisticaSolicitacao.fromMap(m),
        filtros: filtros);
  }
}
