import 'package:sibem_frontend/sibem_frontend.dart';

class CargoService extends RestServiceBase {
  CargoService(RestConfig conf) : super(conf);

  String path = '/cargos';

  Future<DataFrame<Cargo>> all(Filters filtros) async {
    final data = await getDataFrame<Cargo>(path,
        builder: Cargo.fromMap, filtros: filtros);

    return data;
  }

  ///cargos/import/xlsx
  Future<void> importXlsx(String originalFilename, List<int> bytes) async {
    await uploadFileBase({originalFilename: bytes}, '$path/import/xlsx');
  }

  Future<Cargo> getById(int id) async {
    return await getEntity<Cargo>('$path/$id', builder: Cargo.fromMap);
  }

  /// cadastra
  Future<void> insert(Cargo item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Cargo item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> delete(Cargo item) async {
    await deleteEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<Cargo> items) async {
    await deleteAllEntity(items, path);
  }
}
