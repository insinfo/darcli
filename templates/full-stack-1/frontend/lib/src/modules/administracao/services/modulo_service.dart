import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class ModuloService extends RestServiceBase {
  ModuloService(RestConfig conf) : super(conf);

  String path = '/administracao/modulos';

  Future<DataFrame<Modulo>> all(Filters filtros) async {
    var data = await getDataFrame<Modulo>('$path',
        builder: Modulo.fromMap, filtros: filtros);
    return data;
  }

  /// cadastra
  Future<void> insert(Modulo item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Modulo item) async {
    await updateEntity(item, path);
  }

  /// remove
  Future<void> deleteAll(List<Modulo> items) async {
    await deleteAllEntity(items, path);
  }
}
