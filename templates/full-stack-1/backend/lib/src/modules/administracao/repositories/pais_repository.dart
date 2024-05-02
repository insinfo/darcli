import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class PaisRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  PaisRepository(this.db);

  /// lista todos os paises
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table(Pais.tableName);

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

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      query.orderBy('nom_pais');
    }

    var dados = await query.get();

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
