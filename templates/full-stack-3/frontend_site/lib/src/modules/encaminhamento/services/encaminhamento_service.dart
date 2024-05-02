import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class EncaminhamentoService extends RestServiceBase {
  EncaminhamentoService(RestConfig conf) : super(conf);

  String path = '/encaminhamentos';

  Future<DataFrame<Encaminhamento>> all(Filters filtros) async {
    final data = await getDataFrame<Encaminhamento>(path,
        builder: Encaminhamento.fromMap, filtros: filtros);

    return data;
  }

  Future<DataFrame<Encaminhamento>> getAllByEmpregador(
      int idEmpregador, Filters filtros) async {
    final data = await getDataFrame<Encaminhamento>(
        '$path/empregador/$idEmpregador',
        builder: Encaminhamento.fromMap,
        filtros: filtros);
    return data;
  }

  Future<Encaminhamento> getById(int id) async {
    return await getEntity<Encaminhamento>('$path/$id',
        builder: Encaminhamento.fromMap);
  }

  /// cadastra
  Future<void> insert(Encaminhamento item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Encaminhamento item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  // Future<void> delete(Encaminhamento item) async {
  //   await deleteEntity(item, '$path/${item.id}');
  // }

  // Future<void> deleteAll(List<Encaminhamento> items) async {
  //   await deleteAllEntity(items, path);
  // }

  Future<void> updateStatus(Encaminhamento item) async {
    await patchEntity(item, '$path/status/${item.id}');
  }
}
