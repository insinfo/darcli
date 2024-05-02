import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class MunicipioRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  MunicipioRepository(this.db);

  /// lista todos os municipios
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table(Municipio.tableName);

    if (filtros?.isSearch == true) {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString?.toLowerCase()}%';
          }
          query.orWhere(sField.field, sField.operator, filtros.searchString);
        }
      }
    }

    if (filtros?.codUf != null) {
      query.where('cod_uf', '=', filtros?.codUf);
    }

    var dados = await query.get();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      query.orderBy('nom_municipio');
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: dados.length,
    );
  }
}
