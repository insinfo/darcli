import 'package:sibem_frontend/sibem_frontend.dart';

class EscolaridadeService extends RestServiceBase {
  EscolaridadeService(RestConfig conf) : super(conf);

  String path = '/escolaridades';

  Future<DataFrame<Escolaridade>> all(Filters filtros) async {
    final data = await getDataFrame<Escolaridade>(path,
        builder: Escolaridade.fromMap, filtros: filtros);

    return data;
  }

  Future<Escolaridade> getById(int id) async {
    return await getEntity<Escolaridade>('$path/$id', builder: Escolaridade.fromMap);
  }

  /// cadastra
  Future<void> insert(Escolaridade item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Escolaridade item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<Escolaridade> items) async {
    await deleteAllEntity(items, path);
  }
}
