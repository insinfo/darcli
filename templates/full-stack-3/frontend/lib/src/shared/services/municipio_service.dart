import 'package:sibem_frontend/sibem_frontend.dart';

class MunicipioService extends RestServiceBase {
  MunicipioService(RestConfig conf) : super(conf);

  String path = '/municipios';

  Future<DataFrame<Municipio>> all(Filters filtros) async {
    final data = await getDataFrame<Municipio>(path,
        builder: Municipio.fromMap, filtros: filtros);

    return data;
  }

  Future<DataFrame<Municipio>> getAllByIdUf(int idUf) async {
    return await getDataFrame<Municipio>('$path/uf/id/$idUf',
        builder: Municipio.fromMap);
  }

  Future<DataFrame<Municipio>> getAllBySiglaUf(String siglaUf) async {
    return await getDataFrame<Municipio>('$path/uf/sigla/$siglaUf',
        builder: Municipio.fromMap);
  }

  Future<Municipio> getById(int id) async {
    return await getEntity<Municipio>('$path/$id', builder: Municipio.fromMap);
  }

  /// cadastra
  Future<void> insert(Municipio item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Municipio item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<Municipio> items) async {
    await deleteAllEntity(items, path);
  }
}
