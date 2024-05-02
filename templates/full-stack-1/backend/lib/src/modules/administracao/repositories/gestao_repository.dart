import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class GestaoRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  GestaoRepository(this.db);

  /// lista todos as gestoes [Administrativa,Financeira,Patrimonial,Recursos Humanos,Tributaria]
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table(Gestao.tableName);

    if (filtros?.searchString != null && filtros?.searchString?.trim() != '') {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString!.toLowerCase()}%';
            query.whereRaw(
                ''' LOWER(TO_ASCII(${sField.field},'LATIN_1')) like LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
                [filtros.searchString]);
          } else {
            query.where(sField.field, sField.operator, filtros.searchString);
          }
        }
      }
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      //query.orderBy('nom_departamento');
    }

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

  /// lista as gestoes que o usuario tem acesso
  Future<List<Map<String, dynamic>>?> getAllByExercicioAndCgmAsMap(
      String anoExercicio, int numcgm) async {
    final dados = await db.select('''
SELECT DISTINCT 
  G.*
FROM
	administracao.gestao AS G,
	administracao.modulo AS M,
	administracao.funcionalidade AS f,
	administracao.acao AS A,
	administracao.permissao AS P 
WHERE
	G.cod_gestao = M.cod_gestao 
	AND M.cod_modulo = f.cod_modulo 
	AND f.cod_funcionalidade = A.cod_funcionalidade 
	AND A.cod_acao = P.cod_acao 
	AND P.ano_exercicio = '$anoExercicio' 
	AND P.numcgm = $numcgm 
	AND M.cod_modulo > 0 
ORDER BY
	G.ordem
''');

    return dados;
  }

  /// lista as gestoes que o usuario tem acesso
  Future<List<Gestao>> getAllByExercicioAndCgm(
      String anoExercicio, int numcgm) async {
    final dados = await getAllByExercicioAndCgmAsMap(anoExercicio, numcgm);
    return dados is List<Map<String, dynamic>>
        ? dados.map((e) => Gestao.fromMap(e)).toList()
        : [];
  }
}
