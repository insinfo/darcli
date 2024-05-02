import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/rest_config.dart';
import 'package:new_sali_frontend/src/shared/services/rest_service_base.dart';

class SetorService extends RestServiceBase {
  SetorService(RestConfig conf) : super(conf);

  String path = '/administracao/setores';

  Future<DataFrame<Setor>> all(
    Filters filtros, {
    bool removeDisabled = true,
    bool sort = true,
    int? codSelected,
    String? anoSelected,
    int? codDepartamentoSelected,
    int? codUnidadeSelected,
    int? codOrgaoSelected,
  }) async {
    var data = await getDataFrame<Setor>('$path',
        builder: (x) => Setor.fromMap(x), filtros: filtros);

    if (removeDisabled) {
      data.removeWhere((o) => o.nomSetor.toLowerCase().trim().startsWith('x'));
      data.removeWhere((o) => o.situacao == '0');
    }

    if (codSelected != null &&
        anoSelected != null &&
        codDepartamentoSelected != null &&
        codUnidadeSelected != null &&
        codOrgaoSelected != null) {
      for (var org in data) {
        if (org.codSetor == codSelected &&
            org.anoExercicio == anoSelected &&
            org.codDepartamento == codDepartamentoSelected &&
            org.codUnidade == codUnidadeSelected &&
            org.codOrgao == codOrgaoSelected) {
          org.selected = true;
          break;
        }
      }
    }
    if (sort) {
      data.sort((a, b) => a.nomSetor.compareTo(b.nomSetor));
    }
    return data;
  }

  /// cadastra
  Future<void> insert(Setor item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Setor item) async {
    await updateEntity(item, path);
  }

  /// remove
  Future<void> deleteAll(List<Setor> items) async {
    await deleteAllEntity(items, path);
  }
}
