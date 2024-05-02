import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend/src/shared/rest_config.dart';
import 'package:esic_frontend/src/shared/services/rest_service_base.dart';

class SolicitacoesService extends RestServiceBase {
  SolicitacoesService(RestConfig conf) : super(conf);
  String path = '/solicitacoes';

  Future<void> insert(Solicitacao item) async {
    await insertEntity(item, path);
  }

  Future<void> prorrogar(Solicitacao item) async {
    await insertEntity(item, '/prorrogar/solicitacao');
  }

  Future<void> receber(Solicitacao item) async {
    await insertEntity(item, '/receber/solicitacao');
  }

  Future<void> responder(Solicitacao item) async {
    print('SolicitacoesService ${item.anexos}');
    await insertEntityWithAnexos(
      item,
      item.anexos,
      '/responder/solicitacao',
    );
  }

  Future<void> update(Solicitacao item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<DataFrame<Solicitacao>> getAll(Filters filtros) {
    return getDataFrame<Solicitacao>(path, (m) => Solicitacao.fromMap(m),
        filtros: filtros);
  }

  Future<Solicitacao> getById(int id) {
    return getEntity<Solicitacao>('$path/$id', (m) => Solicitacao.fromMap(m));
  }

  Future<void> delete(Solicitacao item) async {
    await deleteEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<Solicitacao> items) async {
    await deleteAllEntity(items, '$path/all/');
  }
}
