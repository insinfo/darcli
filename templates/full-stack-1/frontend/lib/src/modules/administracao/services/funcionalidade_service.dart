import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class FuncionalidadeService extends RestServiceBase {
  FuncionalidadeService(RestConfig conf) : super(conf);

  String path = '/administracao/funcionalidades';

  Future<DataFrame<Funcionalidade>> all(Filters filtros) async {
    var data = await getDataFrame<Funcionalidade>('$path',
        builder: Funcionalidade.fromMap, filtros: filtros);
    return data;
  }

  /// cadastra
  Future<void> insert(Funcionalidade item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Funcionalidade item) async {
    await updateEntity(item, path);
  }

  /// remove
  Future<void> deleteAll(List<Funcionalidade> items) async {
    await deleteAllEntity(items, path);
  }
}
