import 'package:esic_core/esic_core.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

class ExtraRepository {
  final DbLayer db;
  ExtraRepository(this.db);

  Future<DataFrame<Map<String, dynamic>>> getAllTipoTelefone(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('*').from('lda_tipotelefone');
    final totalRecords = 4; //await query.count();
    var dados = await query.getAsMap();
    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllFaixaEtaria(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('*').from('lda_faixaetaria');

    final totalRecords = await query.count();
    query.order('idfaixaetaria');
    var dados = await query.getAsMap();
    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllEscolaridade(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('*').from('lda_escolaridade');

    final totalRecords = await query.count();

    query.order('idescolaridade');
    var dados = await query.getAsMap();
    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllPaises(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('*').from('gen_paises');
    final totalRecords = 102; //await query.count();
    var dados = await query.getAsMap();
    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllEstados(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('*').from('gen_estados');
    final totalRecords = 27; //await query.count(); // 27;
    var dados = await query.getAsMap();
    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllMunicipios(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('*').from('gen_municipios');
    final totalRecords = await query.count(); // 10061;
    var dados = await query.getAsMap();
    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllTiposLogradouro(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('*').from('gen_tipos_logradouro');
    final totalRecords = 2014; //await query.count();
    var dados = await query.getAsMap();
    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllCargos(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw(''' * ''').from('cargos');

    if (filtros?.isSearch == true) {
      query.whereGroup((q) {
        for (var sField in filtros!.searchInFields) {
          if (sField.active) {
            if (sField.operator == 'ilike' || sField.operator == 'like') {
              var substitutionField = sField.field;
              if (sField.field.contains('.')) {
                substitutionField = sField.field.split('.').last;
              }
              var substitutionValues = {
                substitutionField: '%${filtros.searchString?.toLowerCase()}%',
              };

              q.whereRaw(
                  'LOWER(${db.putInQuotes(sField.field)}::text) like ${db.formatSubititutioValue(sField.field)}',
                  andOr: 'OR',
                  substitutionValues: substitutionValues);
            } else {
              q.orWhereSafe(
                  '"${sField.field}"', sField.operator, filtros.searchString);
            }
          }
        }
        return q;
      });
    }
    // print(query.toSql());
    final totalRecords = await query.count();
    if (filtros?.isOrder == true) {
      query.order(filtros!.orderBy!,
          dir: filtros.orderDir == 'asc' ? SortOrder.ASC : SortOrder.DESC);
    }
    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }
    var dados = await query.getAsMap();
    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }
}
