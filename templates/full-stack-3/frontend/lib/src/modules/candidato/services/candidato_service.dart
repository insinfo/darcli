import 'package:sibem_frontend/sibem_frontend.dart';

class CandidatoService extends RestServiceBase {
  CandidatoService(RestConfig conf) : super(conf);

  String path = '/candidatos';

  Future<DataFrame<Candidato>> all(Filters filtros) async {
    final data = await getDataFrame<Candidato>(path,
        builder: Candidato.fromMap, filtros: filtros);
    return data;
  }

  Future<Candidato> getById(int id) async {
    return await getEntity<Candidato>('$path/$id', builder: Candidato.fromMap);
  }

  /// cadastra
  Future<void> insert(Candidato item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Candidato item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<Candidato> items) async {
    await deleteAllEntity(items, path);
  }
}
