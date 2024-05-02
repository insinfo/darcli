import 'package:sibem_frontend/sibem_frontend.dart';

class CandidatoWebService extends RestServiceBase {
  CandidatoWebService(RestConfig conf) : super(conf);

  String path = '/candidatos-web';

  Future<DataFrame<CandidatoWeb>> all(Filters filtros) async {
    final data = await getDataFrame<CandidatoWeb>(path,
        builder: CandidatoWeb.fromMap, filtros: filtros);
    return data;
  }

  Future<CandidatoWeb> getById(int id) async {
    return await getEntity<CandidatoWeb>('$path/$id', builder: CandidatoWeb.fromMap);
  }

  /// cadastra
  Future<void> insert(CandidatoWeb item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(CandidatoWeb item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<CandidatoWeb> items) async {
    await deleteAllEntity(items, path);
  }
}
