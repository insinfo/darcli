import 'package:esic_core/esic_core.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

class EstatisticaRepository {
  final DbLayer db;
  EstatisticaRepository(this.db);

  /// recupera o quantitativo de solicitacoes em aberto e respondidas por ano
  Future<DataFrame<Map<String, dynamic>>> solicitacoesPorAno(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('''
    anoprotocolo as ano, 
		count(*) as total
    ''').from('lda_solicitacao');

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
    query.group('anoprotocolo');

    //print(query.toSql());
    //final totalRecords = 0; //await query.count();

    if (filtros?.isOrder == true) {
      query.order(filtros!.orderBy!,
          dir: filtros.orderDir == 'asc' ? SortOrder.ASC : SortOrder.DESC);
    } else {
      query.order('anoprotocolo', dir: SortOrder.ASC);
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    //print(query.toSql());
    var dados = await query.getAsMap();

    if (dados.isNotEmpty == true) {
      for (var item in dados) {
        //	$sql="select count(*) as tot from lda_solicitacao where anoprotocolo = ".$row['ano']." and situacao in('R','N')";
        var result = await db
            .select()
            .fieldRaw('count(*) as respondidas')
            .from('lda_solicitacao')
            .whereRaw(
                "anoprotocolo = '${item['ano']}' and situacao in('R','N')")
            .firstAsMap();
        item['respondidas'] = result != null ? result['respondidas'] : 0;
      }
    }

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: dados.length,
    );
  }
}
