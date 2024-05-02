import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend/src/shared/rest_config.dart';
import 'package:esic_frontend/src/shared/services/rest_service_base.dart';

class ExtraService extends RestServiceBase {
  ExtraService(RestConfig conf) : super(conf);
  String path = '/extra';

  Future<DataFrame<FaixaEtaria>> getAllFaixaEtaria({Filters? filtros}) {
    return getDataFrame<FaixaEtaria>(
        '$path/faixaetarias', (m) => FaixaEtaria.fromMap(m),
        filtros: filtros);
  }

  Future<DataFrame<Escolaridade>> getAllEscolaridade({Filters? filtros}) {
    return getDataFrame<Escolaridade>(
        '$path/escolaridades', (m) => Escolaridade.fromMap(m),
        filtros: filtros);
  }

  Future<DataFrame<Pais>> getAllPaises({Filters? filtros}) {
    return getDataFrame<Pais>('$path/paises', (m) => Pais.fromMap(m),
        filtros: filtros);
  }

  Future<DataFrame<Municipio>> getAllMunicipios({Filters? filtros}) {
    return getDataFrame<Municipio>(
        '$path/municipios', (m) => Municipio.fromMap(m),
        filtros: filtros);
  }

  Future<DataFrame<TipoLograduro>> getAllTiposLogradouro({Filters? filtros}) {
    return getDataFrame<TipoLograduro>(
        '$path/tiposlogradouro', (m) => TipoLograduro.fromMap(m),
        filtros: filtros);
  }

  Future<DataFrame<Cargo>> getAllCargos({Filters? filtros}) {
    return getDataFrame<Cargo>('$path/cargos', (m) => Cargo.fromMap(m),
        filtros: filtros);
  }

  Future<DataFrame<TipoTelefone>> getAllTipoTelefone({Filters? filtros}) {
    return getDataFrame<TipoTelefone>(
        '$path/tipotelefones', (m) => TipoTelefone.fromMap(m),
        filtros: filtros);
  }

  Future<DataFrame<Estado>> getAllEstados({Filters? filtros}) {
    return getDataFrame<Estado>('$path/estados', (m) => Estado.fromMap(m),
        filtros: filtros);
  }
}
