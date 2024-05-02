import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class AcaoService extends RestServiceBase {
  AcaoService(RestConfig conf) : super(conf);

  String path = '/administracao/acoes';

  Future<DataFrame<Acao>> all(Filters filtros) async {
    var data = await getDataFrame<Acao>('$path',
        builder: Acao.fromMap, filtros: filtros);
    return data;
  }

  /// cadastra
  Future<void> insert(Acao item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Acao item) async {
    await updateEntity(item, path);
  }

  /// remove
  Future<void> deleteAll(List<Acao> items) async {
    await deleteAllEntity(items, path);
  }
}
