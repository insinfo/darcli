import 'package:sibem_frontend/sibem_frontend.dart';

class AuditoriaService extends RestServiceBase {
  AuditoriaService(RestConfig conf) : super(conf);

  String path = '/auditorias';

  Future<DataFrame<Auditoria>> all(Filters filtros) async {
    final data = await getDataFrame<Auditoria>(path,
        builder: Auditoria.fromMap, filtros: filtros);

    return data;
  }

  Future<Auditoria> getById(int id) async {
    return await getEntity<Auditoria>('$path/$id', builder: Auditoria.fromMap);
  }

  /// cadastra
  Future<void> insert(Auditoria item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Auditoria item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<Auditoria> items) async {
    await deleteAllEntity(items, path);
  }
}
