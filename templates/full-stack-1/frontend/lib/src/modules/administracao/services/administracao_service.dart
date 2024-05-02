import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/rest_config.dart';
import 'package:new_sali_frontend/src/shared/services/rest_service_base.dart';

class AdministracaoService extends RestServiceBase {
  AdministracaoService(RestConfig conf) : super(conf);

  String path = '/administracao';

  Future<DataFrame<Escolaridade>> getEscolaridades(Filters filtros) {
    return getDataFrame<Escolaridade>('$path/escolaridades',
        builder: (x) => Escolaridade.fromMap(x), filtros: filtros);
  }

  /// lista tipo de logradouro (Rua, Avenida...)
  Future<DataFrame<TipoLogradouro>> getTiposLogradouros(Filters filtros) {
    return getDataFrame<TipoLogradouro>('$path/tiposlogradouro',
        builder: TipoLogradouro.fromMap, filtros: filtros);
  }

  Future<DataFrame<Pais>> getPaises(Filters filtros) {
    return getDataFrame<Pais>('$path/paises',
        builder: (x) => Pais.fromMap(x), filtros: filtros);
  }

  /// lista Unidades federativas do Brasil
  Future<DataFrame<UnidadeFederativa>> getUfs(Filters filtros) {
    return getDataFrame<UnidadeFederativa>('$path/ufs',
        builder: (x) => UnidadeFederativa.fromMap(x), filtros: filtros);
  }

  /// lista municipios
  Future<DataFrame<Municipio>> getMunicipios(Filters filtros) {
    return getDataFrame<Municipio>('$path/municipios',
        builder: (x) => Municipio.fromMap(x), filtros: filtros);
  }

  /// lista Auditorias
  Future<DataFrame<Auditoria>> getAuditorias(Filters filtros) {
    return getDataFrame<Auditoria>('$path/auditorias',
        builder: (x) => Auditoria.fromMap(x), filtros: filtros);
  }

  /// lista Modulos
  Future<DataFrame<Modulo>> getModulos(Filters filtros) {
    return getDataFrame<Modulo>('$path/modulos',
        builder: (x) => Modulo.fromMap(x), filtros: filtros);
  }



  /// lista usuarios
  Future<DataFrame<Usuario>> getUsuarios(Filters filtros) {
    return getDataFrame<Usuario>('$path/usuarios',
        builder: (x) => Usuario.fromMap(x), filtros: filtros);
  }
}
