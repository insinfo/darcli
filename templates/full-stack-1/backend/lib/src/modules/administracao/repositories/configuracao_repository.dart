import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class ConfiguracaoRepository {
  final Connection db;

  ConfiguracaoRepository(this.db);

  /// lista os configurações
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table(Configuracao.tableName);

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
      //query.orderBy('nom_departamento');
    }
    final totalRecords = 0; //await query.count('numcgm');

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    final dados = await query.get();

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<List<Configuracao>> getAllByModuloAndExercicio(
      int codModulo, String anoExercicio) async {
    var query = db.table(Configuracao.tableName);
    query.where('cod_modulo', '=', codModulo);
    query.where('exercicio', '=', anoExercicio);
    final dados = await query.get();
    return dados.isNotEmpty
        ? dados.map((e) => Configuracao.fromMap(e)).toList()
        : [];
  }

  Future<Configuracao?> getByModuloExercicioParametro(
      int codModulo, String anoExercicio, String parametro) async {
    var query = db.table(Configuracao.tableName);
    query.where('cod_modulo', '=', codModulo);
    query.where('exercicio', '=', anoExercicio);
    query.where('parametro', '=', parametro);
    final dados = await query.first();
    return dados is Map<String, dynamic> ? Configuracao.fromMap(dados) : null;
  }

  Future<Map<String, dynamic>?> getByModuloExercicioParametroAsMap(
      int? codModulo, String? anoExercicio, String? parametro) async {
    var query = db.table(Configuracao.tableName);
    query.where('cod_modulo', '=', codModulo);
    query.where('exercicio', '=', anoExercicio);
    query.where('parametro', '=', parametro);
    //query.limit(1);
    final dados = await query.first();
    return dados is Map<String, dynamic> ? dados : null;
  }
}
