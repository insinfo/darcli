import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/rest_config.dart';

import 'rest_service_base.dart';

class ConfiguracaoService extends RestServiceBase {
  ConfiguracaoService(RestConfig conf) : super(conf);

  String path = '/administracao/configuracao';

  Future<Configuracao> getByFiltro(Filters filters) {
    return getEntity<Configuracao>('$path/by/filtro',
        builder: Configuracao.fromMap, queryParameters: filters.getParams());
  }
}
