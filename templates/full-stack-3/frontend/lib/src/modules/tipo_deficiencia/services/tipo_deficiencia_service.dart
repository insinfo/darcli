import 'package:sibem_frontend/sibem_frontend.dart';

class TipoDeficienciaService extends RestServiceBase {
  TipoDeficienciaService(RestConfig conf) : super(conf);

  String path = '/tipos-deficiencia';

  Future<DataFrame<TipoDeficiencia>> all(Filters filtros) async {
    final data = await getDataFrame<TipoDeficiencia>(path,
        builder: TipoDeficiencia.fromMap, filtros: filtros);

    return data;
  }

  Future<TipoDeficiencia> getById(int id) async {
    return await getEntity<TipoDeficiencia>('$path/$id', builder: TipoDeficiencia.fromMap);
  }

  /// cadastra
  Future<void> insert(TipoDeficiencia item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(TipoDeficiencia item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<TipoDeficiencia> items) async {
    await deleteAllEntity(items, path);
  }
}
