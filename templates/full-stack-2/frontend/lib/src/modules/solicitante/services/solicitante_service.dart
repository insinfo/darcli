import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend/src/shared/rest_config.dart';
import 'package:esic_frontend/src/shared/services/rest_service_base.dart';

class SolicitanteService extends RestServiceBase {
  SolicitanteService(RestConfig conf) : super(conf);
  String path = '/solicitantes';

  Future<void> insert(Solicitante solicitante) async {
    await insertEntity(solicitante, path);
  }

  Future<void> update(Solicitante solicitante) async {
    await updateEntity(solicitante, '$path/${solicitante.id}');
  }

  Future<DataFrame<Solicitante>> getAll(Filters filtros) {
    return getDataFrame<Solicitante>(path, (m) => Solicitante.fromMap(m),
        filtros: filtros);
  }

  Future<Solicitante> getById(int id) {
    return getEntity<Solicitante>('$path/$id', (m) => Solicitante.fromMap(m));
  }

  Future<void> delete(Solicitante solicitante) async {
    await deleteEntity(solicitante, '$path/${solicitante.id}');
  }

  Future<void> deleteAll(List<Solicitante> items) async {
    await deleteAllEntity(items, '$path/all/');
  }
}
