import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/rest_config.dart';
import 'package:new_sali_frontend/src/shared/services/rest_service_base.dart';

class DepartamentoService extends RestServiceBase {
  DepartamentoService(RestConfig conf) : super(conf);

  String path = '/administracao/departamentos';

  /// [removeDisabled] remove os desativados (que o nome inicia com a letra x)
  /// [codSelected] é o cod_departamento a ser usado para definir a propriedade `selected = true`
  /// [anoSelected] é o ano execicio a ser usado para definir a propriedade `selected = true`
  Future<DataFrame<Departamento>> all(
    Filters filtros, {
    bool removeDisabled = true,
    bool sort = true,
    int? codSelected,
    String? anoSelected,
    int? codUnidadeSelected,
    int? codOrgaoSelected,
  }) async {
    var data = await getDataFrame<Departamento>('$path',
        builder: (x) => Departamento.fromMap(x), filtros: filtros);

    if (removeDisabled) {
      data.removeWhere(
          (o) => o.nomDepartamento.toLowerCase().trim().startsWith('x'));
    }

    if (codSelected != null &&
        anoSelected != null &&
        codUnidadeSelected != null &&
        codOrgaoSelected != null) {
      for (var org in data) {
        if (org.codDepartamento == codSelected &&
            org.anoExercicio == anoSelected &&
            org.codUnidade == codUnidadeSelected &&
            org.codOrgao == codOrgaoSelected) {
          org.selected = true;
          break;
        }
      }
    }

    if (sort) {
      data.sort((a, b) => a.nomDepartamento.compareTo(b.nomDepartamento));
    }
    return data;
  }

  /// cadastra
  Future<void> insert(Departamento item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(Departamento item) async {
    await updateEntity(item, path);
  }

  /// remove
  Future<void> deleteAll(List<Departamento> items) async {
    await deleteAllEntity(items, path);
  }
}
