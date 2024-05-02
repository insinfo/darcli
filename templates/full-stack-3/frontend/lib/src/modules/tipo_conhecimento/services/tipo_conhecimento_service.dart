import 'package:sibem_frontend/sibem_frontend.dart';

class TipoConhecimentoService extends RestServiceBase {
  TipoConhecimentoService(RestConfig conf) : super(conf);

  String path = '/tipos-conhecimento';

  Future<DataFrame<TipoConhecimento>> all(Filters filtros) async {
    final data = await getDataFrame<TipoConhecimento>(path,
        builder: TipoConhecimento.fromMap, filtros: filtros);

    return data;
  }

  Future<TipoConhecimento> getById(int id) async {
    return await getEntity<TipoConhecimento>('$path/$id', builder: TipoConhecimento.fromMap);
  }

  /// cadastra
  Future<void> insert(TipoConhecimento item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(TipoConhecimento item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<TipoConhecimento> items) async {
    await deleteAllEntity(items, path);
  }
}
