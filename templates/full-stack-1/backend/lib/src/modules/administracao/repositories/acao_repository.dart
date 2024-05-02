import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class AcaoRepository {
  final Connection db;

  AcaoRepository(this.db);

  /// lista todas as ações
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    final query = db.table(Acao.fqtn);
    query.selectRaw('acao.*');
    query.join('administracao.funcionalidade',
        'funcionalidade.cod_funcionalidade', '=', 'acao.cod_funcionalidade');

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

    if (filtros?.codFuncionalidade != null) {
      query.where('acao.cod_funcionalidade', '=', filtros!.codFuncionalidade);
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

  Future<List<Acao>> getAllByExercicioCgmFuncionalidade(
      String anoExercicio, int numcgm, List<int> codsFuncionalidade) async {
    final dados = await db.select('''
  SELECT
      DISTINCT a.ordem,
      m.cod_modulo,
      m.nom_modulo,
      f.cod_funcionalidade,
      f.nom_funcionalidade,
      a.nom_acao,
      a.nom_arquivo,
      a.parametro,
      a.complemento_acao,
      f.nom_diretorio as func_dir,
      m.nom_diretorio as mod_dir,
      g.nom_diretorio as gest_dir,
      a.cod_acao,
      a.habilitada
  FROM
      administracao.gestao as g,
      administracao.modulo as m,
      administracao.funcionalidade as f,
      administracao.acao as a,
      administracao.permissao as p
  WHERE
      g.cod_gestao = m.cod_gestao AND
      m.cod_modulo = f.cod_modulo AND
      f.cod_funcionalidade = a.cod_funcionalidade AND
      a.cod_acao = p.cod_acao AND
      a.cod_funcionalidade in (${codsFuncionalidade.join(',')}) AND
      p.numcgm='$numcgm' AND
      p.ano_exercicio = '$anoExercicio'
  ORDER by
      a.ordem''');

    return dados.isNotEmpty
        ? dados.map((e) => Acao.fromMap(e)).toList()
        : <Acao>[];
  }

  /// lista as ações que o usuario tem acesso
  /// [numcgm] é o id do usuario/pessoa
  Future<List<Acao>> getAllByExercicioAndCgm(
      String anoExercicio, int numcgm) async {
    final dados = await db.select('''
SELECT
	administracao.permissao.numcgm,
	administracao.acao.*
FROM
	administracao.permissao 
JOIN administracao.acao ON administracao.acao.cod_acao = administracao.permissao.cod_acao
WHERE
	administracao.permissao.numcgm = '$numcgm' 
	AND administracao.permissao.ano_exercicio = '$anoExercicio'
''');

    return dados.isNotEmpty
        ? dados.map((e) => Acao.fromMap(e)).toList()
        : <Acao>[];
  }

  Future<List<Acao>> getAcoesHomeByExercicioAndCgm(
      String anoExercicio, int numcgm) async {
    final dados = await db.select('''
SELECT
	administracao.permissao.numcgm,	
	administracao.acao.*
FROM
	administracao.permissao 
JOIN administracao.acao ON administracao.acao.cod_acao = administracao.permissao.cod_acao
WHERE
	administracao.permissao.numcgm = '$numcgm' 
	AND administracao.permissao.cod_acao IN (67,59,58,127,61,1624) 
	AND administracao.permissao.ano_exercicio = '$anoExercicio'
''');

    return dados.isNotEmpty
        ? dados.map((e) => Acao.fromMap(e)).toList()
        : <Acao>[];
  }

  Future<void> insert(Acao item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

    // verifica se ja existe
    final isExist = await conn
        .table(Acao.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_acao,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomAcao])
        .where('cod_funcionalidade', '=', item.codFuncionalidade)
        .first();

    if (isExist != null) {
      throw Exception('Já existe uma ação com este nome');
    }

    // pega codigo anterior
    final lastId = await conn
        .table('administracao.acao')
        .selectRaw('''MAX(cod_acao) AS codigo''')
        //.where('cod_funcionalidade', '=', item.codFuncionalidade)
        .first();

    final nextId = lastId == null || lastId['codigo'] == null
        ? 1
        : (lastId['codigo'] as int) + 1;

    item.codAcao = nextId;

    // grava
    await conn.table(Acao.fqtn).insert(item.toInsertMap());
  }

  Future<void> update(Acao item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    // verifica se ja existe
    final isExist = await conn
        .table(Acao.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_acao,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomAcao])
        .where('cod_funcionalidade', '=', item.codFuncionalidade)
        .first();

    if (isExist != null) {
      throw Exception('Já existe uma ação com este nome');
    }
    //UPDATE
    await conn
        .table(Acao.fqtn)
        .where('cod_acao', '=', item.codAcao)
        .update(item.toUpdateMap());
  }

  Future<void> delete(Acao item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    await conn.table(Acao.fqtn).where('cod_acao', '=', item.codAcao).delete();
  }
}
