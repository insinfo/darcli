import 'package:sibem_frontend/sibem_frontend.dart';

class EmpregadorService extends RestServiceBase {
  EmpregadorService(RestConfig conf) : super(conf);

  String path = '/empregadores';

  Future<DataFrame<Empregador>> all(Filters filtros) async {
    final data = await getDataFrame<Empregador>(path,
        builder: Empregador.fromMap, filtros: filtros);
    return data;
  }

  Future<Empregador> getById(int id) async {
    return await getEntity<Empregador>('$path/$id',
        builder: Empregador.fromMap);
  }

  /// cadastra
  Future<void> insert(Empregador item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Empregador item) async {
    await updateEntity(item, '$path/${item.idPessoa}');
  }

  Future<void> deleteAll(List<Empregador> items) async {
    await deleteAllEntity(items, path);
  }
}
