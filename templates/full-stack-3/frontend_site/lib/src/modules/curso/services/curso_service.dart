import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class CursoService extends RestServiceBase {
  CursoService(RestConfig conf) : super(conf);

  String path = '/cursos';

  Future<DataFrame<Curso>> all(Filters filtros) async {
    final data = await getDataFrame<Curso>(path,
        builder: Curso.fromMap, filtros: filtros);

    return data;
  }

  Future<void> importXlsx(String originalFilename, List<int> bytes) async {
    await uploadFileBase({originalFilename: bytes}, '$path/import/xlsx');
  }

  Future<Curso> getById(int id) async {
    return await getEntity<Curso>('$path/$id', builder: Curso.fromMap);
  }

  /// cadastra
  Future<void> insert(Curso item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Curso item) async {
    await updateEntity(item, '$path/${item.id}');
  }

  Future<void> deleteAll(List<Curso> items) async {
    await deleteAllEntity(items, path);
  }
}
