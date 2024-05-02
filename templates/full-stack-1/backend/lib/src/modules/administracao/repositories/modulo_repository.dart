import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class ModuloRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  ModuloRepository(this.db);

  /// lista os modulos
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table(Modulo.fqtn);

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

    if (filtros?.codGestao != null) {
      query.where('modulo.cod_gestao', '=', filtros!.codGestao);
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

  /// lista os modulos que o usuario tem acesso
  Future<List<Map<String, dynamic>>?> getAllByExercicioCgmGestoesAsMap(
      String anoExercicio, int numcgm, List<int> codsGestao) async {
    final dados = await db.select('''
SELECT DISTINCT 
  M.*
FROM
	administracao.gestao AS G,
	administracao.modulo AS M,
	administracao.funcionalidade AS f,
	administracao.acao AS A,
	administracao.permissao AS P 
WHERE
	G.cod_gestao = M.cod_gestao 
	AND P.numcgm = $numcgm 
	AND M.cod_modulo = f.cod_modulo 
	AND f.cod_funcionalidade = A.cod_funcionalidade 
	AND A.cod_acao = P.cod_acao 
	AND P.ano_exercicio = '$anoExercicio' 
	AND M.cod_gestao in (${codsGestao.join(',')})
	AND M.cod_modulo > 0 
ORDER BY
	M.ordem
''');
    return dados;
  }

  /// lista os modulos que o usuario tem acesso
  Future<List<Modulo>> getAllByExercicioCgmGestoes(
      String anoExercicio, int numcgm, List<int> codsGestao) async {
    final dados = await getAllByExercicioCgmGestoesAsMap(
        anoExercicio, numcgm, codsGestao);
    return dados is List<Map<String, dynamic>>
        ? dados.map((e) => Modulo.fromMap(e)).toList()
        : [];
  }

  Future<void> insert(Modulo item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

    // verifica se ja existe
    final isExist = await conn
        .table(Modulo.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_modulo,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomFuncionalidade])
        .where('cod_modulo', '<>', item.codModulo)
        .first();

    if (isExist != null) {
      throw Exception('Já existe um Modulo com este nome');
    }

    // pega codigo anterior
    final lastId = await conn
        .table('administracao.modulo')
        .selectRaw('''MAX(cod_modulo) AS codigo''').first();

    final nextId = lastId == null || lastId['codigo'] == null
        ? 1
        : (lastId['codigo'] as int) + 1;

    item.codModulo = nextId;

    // grava
    await conn.table(Modulo.fqtn).insert(item.toInsertMap());
  }

  Future<void> update(Modulo item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    // verifica se ja existe
    final isExist = await conn
        .table(Modulo.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_modulo,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomFuncionalidade])
        .where('cod_modulo', '<>', item.codModulo)
        .first();

    if (isExist != null) {
      throw Exception('Já existe um Modulo com este nome');
    }

    //UPDATE
    await conn
        .table(Modulo.fqtn)
        .where('cod_modulo', '=', item.codModulo)
        .update(item.toUpdateMap());
  }

  Future<void> delete(Modulo item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    await conn
        .table(Modulo.fqtn)
        .where('cod_modulo', '=', item.codModulo)
        .delete();
  }
}
