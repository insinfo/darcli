import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class VagaService extends RestServiceBase {
  VagaService(RestConfig conf) : super(conf);

  String path = '/vagas';

  Future<DataFrame<Vaga>> all(Filters filtros) async {
    final data =
        await getDataFrame<Vaga>(path, builder: Vaga.fromMap, filtros: filtros);
    return data;
  }

  Future<Vaga> getById(int id) async {
    return await getEntity<Vaga>('$path/$id', builder: Vaga.fromMap);
  }

  /// cadastra
  Future<void> insert(Vaga item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Vaga item) async {
    await updateEntity(item, '$path/${item.id}');
  }
}
