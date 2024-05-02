import 'package:sibem_frontend/sibem_frontend.dart';

class ConhecimentoExtraService extends RestServiceBase {
  ConhecimentoExtraService(RestConfig conf) : super(conf);

  String path = '/conhecimentos-extra';

  Future<DataFrame<ConhecimentoExtra>> all(Filters filtros) async {
    final data = await getDataFrame<ConhecimentoExtra>(path,
        builder: ConhecimentoExtra.fromMap, filtros: filtros);

    return data;
  }

  Future<ConhecimentoExtra> getById(int id) async {
    return await getEntity<ConhecimentoExtra>('$path/$id', builder: ConhecimentoExtra.fromMap);
  }

  /// cadastra
  Future<void> insert(ConhecimentoExtra item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(ConhecimentoExtra item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<ConhecimentoExtra> items) async {
    await deleteAllEntity(items, path);
  }
}
