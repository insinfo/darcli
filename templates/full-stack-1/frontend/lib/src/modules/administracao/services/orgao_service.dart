import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class OrgaoService extends RestServiceBase {
  OrgaoService(RestConfig conf) : super(conf);

  String path = '/administracao/orgaos';

  Future<DataFrame<Orgao>> all(Filters filtros,
      {bool removeDisabled = true,
      bool sort = true,
      int? codSelected,
      String? anoSelected}) async {
    var data = await getDataFrame<Orgao>('$path',
        builder: (x) => Orgao.fromMap(x), filtros: filtros);

    if (removeDisabled) {
      data.removeWhere((o) => o.nomOrgao.toLowerCase().trim().startsWith('x'));
    }

    if (codSelected != null && anoSelected != null) {
      for (var org in data) {
        if (org.codOrgao == codSelected && org.anoExercicio == anoSelected) {
          org.selected = true;
          break;
        }
      }
    }

    if (sort) {
      data.sort((a, b) => a.nomOrgao.compareTo(b.nomOrgao));
    }
    return data;
  }

  /// cadastra
  Future<void> insert(Orgao item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Orgao item) async {
    await updateEntity(item, path);
  }

  /// remove
  Future<void> deleteAll(List<Orgao> items) async {
    await deleteAllEntity(items, path);
  }
}
