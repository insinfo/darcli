import 'package:sibem_frontend/sibem_frontend.dart';

class EmpregadorWebServiceWeb extends RestServiceBase {
  EmpregadorWebServiceWeb(RestConfig conf) : super(conf);

  String path = '/empregadores-web';

  Future<DataFrame<EmpregadorWeb>> all(Filters filtros) async {
    final data = await getDataFrame<EmpregadorWeb>(path,
        builder: EmpregadorWeb.fromMap, filtros: filtros);
    return data;
  }

  Future<EmpregadorWeb> getById(int id) async {
    return await getEntity<EmpregadorWeb>('$path/$id',
        builder: EmpregadorWeb.fromMap);
  }

  /// cadastra
  Future<void> insert(EmpregadorWeb item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(EmpregadorWeb item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> updateStatus(EmpregadorWeb item) async {
    await patchEntity(item, '$path/status/${item.id}');
  }

  Future<void> deleteAll(List<EmpregadorWeb> items) async {
    await deleteAllEntity(items, path);
  }
}
