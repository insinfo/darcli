import 'package:sibem_frontend/sibem_frontend.dart';

class DivisaoCnaeService extends RestServiceBase {
  DivisaoCnaeService(RestConfig conf) : super(conf);

  String path = '/divisoes-cnae';

  Future<DataFrame<DivisaoCnae>> all(Filters filtros) async {
    final data = await getDataFrame<DivisaoCnae>(path,
        builder: DivisaoCnae.fromMap, filtros: filtros);

    return data;
  }

  Future<DivisaoCnae> getById(int id) async {
    return await getEntity<DivisaoCnae>('$path/$id', builder: DivisaoCnae.fromMap);
  }

  /// cadastra
  Future<void> insert(DivisaoCnae item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(DivisaoCnae item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<DivisaoCnae> items) async {
    await deleteAllEntity(items, path);
  }
}
