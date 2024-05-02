import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class GestaoService extends RestServiceBase {
  GestaoService(RestConfig conf) : super(conf);

  String path = '/administracao/gestoes';

  Future<DataFrame<Gestao>> all(Filters filtros) async {
    var data = await getDataFrame<Gestao>('$path',
        builder: Gestao.fromMap, filtros: filtros);
    return data;
  }

  /// cadastra
  Future<void> insert(Gestao item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Gestao item) async {
    await updateEntity(item, path);
  }

  /// remove
  Future<void> deleteAll(List<Gestao> items) async {
    await deleteAllEntity(items, path);
  }
}
