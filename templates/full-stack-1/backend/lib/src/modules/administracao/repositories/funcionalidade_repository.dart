import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class FuncionalidadeRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  FuncionalidadeRepository(this.db);

  /// lista funcionalidades
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    var query = db.table('administracao.funcionalidade');

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

    if (filtros?.codModulo != null) {
      query.where('funcionalidade.cod_modulo', '=', filtros!.codModulo);
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

  Future<List<Funcionalidade>> getAllByExercicioCgmModulos(
      String anoExercicio, int numcgm, List<int> codsModulo) async {
    final dados = await db.select('''
SELECT
	f.*,
	M.nom_modulo 
FROM
	administracao.modulo AS M,
	administracao.funcionalidade AS f,
	(
	SELECT A
		.cod_funcionalidade 
	FROM
		administracao.acao AS A,
		administracao.permissao AS P 
	WHERE
		A.cod_acao = P.cod_acao 
		AND P.numcgm = '$numcgm' 
		AND P.ano_exercicio = '$anoExercicio' 
	GROUP BY
		A.cod_funcionalidade 
	) AS A 
WHERE
	M.cod_modulo = f.cod_modulo 
	AND f.cod_funcionalidade = A.cod_funcionalidade 
	AND f.cod_modulo in (${codsModulo.join(',')}) 
ORDER BY
	f.ordem
''');

    return dados.isNotEmpty
        ? dados.map((e) => Funcionalidade.fromMap(e)).toList()
        : [];
  }

  Future<void> insert(Funcionalidade item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

    // verifica se ja existe
    final isExist = await conn
        .table(Funcionalidade.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_funcionalidade,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomFuncionalidade])
        .where('cod_funcionalidade', '<>', item.codFuncionalidade)
        .first();

    if (isExist != null) {
      throw Exception('Já existe uma Funcionalidade com este nome');
    }

    // pega codigo anterior
    final lastId = await conn
        .table('administracao.acao')
        .selectRaw('''MAX(cod_funcionalidade) AS codigo''').first();

    final nextId = lastId == null || lastId['codigo'] == null
        ? 1
        : (lastId['codigo'] as int) + 1;

    item.codFuncionalidade = nextId;

    // grava
    await conn.table(Funcionalidade.fqtn).insert(item.toInsertMap());
  }

  Future<void> update(Funcionalidade item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    // verifica se ja existe
    final isExist = await conn
        .table(Funcionalidade.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_funcionalidade,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomFuncionalidade])
        .where('cod_funcionalidade', '<>', item.codFuncionalidade)
        .first();

    if (isExist != null) {
      throw Exception('Já existe uma Funcionalidade com este nome');
    }

    //UPDATE
    await conn
        .table(Funcionalidade.fqtn)
        .where('cod_funcionalidade', '=', item.codFuncionalidade)
        .update(item.toUpdateMap());
  }

  Future<void> delete(Funcionalidade item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    await conn
        .table(Funcionalidade.fqtn)
        .where('cod_funcionalidade', '=', item.codFuncionalidade)
        .delete();
  }
}
