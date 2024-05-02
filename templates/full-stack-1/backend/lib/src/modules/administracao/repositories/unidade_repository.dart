import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class UnidadeRepository {
  /// Conexão com o banco de dados
  final Connection db;

  UnidadeRepository(this.db);

  /// lista todas as unidades
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    final query = db.table('administracao.unidade');
    query.selectRaw('''unidade.*, orgao.nom_orgao  ''');
    query.join('administracao.orgao', (JoinClause jc) {
      jc.on('orgao.cod_orgao', '=', 'unidade.cod_orgao');
      jc.on('orgao.ano_exercicio', '=', 'unidade.ano_exercicio');
    });

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

    if (filtros?.codOrgao != null) {
      query.where('unidade.cod_orgao', '=', filtros!.codOrgao);
    }
    if (filtros?.anoExercicio != null) {
      query.where('unidade.ano_exercicio', '=', filtros!.anoExercicio);
    }
    if (filtros?.situacao != null) {
      query.where('unidade.situacao', '=', filtros!.situacao);
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      query
          .orderByRaw('lower(orgao.nom_orgao), lower(unidade.nom_unidade) ASC');
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

  Future<List<Unidade>> getAllUnidade(
      {int? codOrgao,
      String? anoExercicio,
      bool removeDisabled = false,
      bool sort = true}) async {
    final query = db.table('administracao.unidade');
    if (codOrgao != null) {
      query.where('cod_orgao', '=', codOrgao);
    }
    if (anoExercicio != null) {
      query.where('ano_exercicio', '=', anoExercicio);
    }
    final dados = await query.get();
    final results = dados.map((e) => Unidade.fromMap(e)).toList();

    if (removeDisabled) {
      results.removeWhere(
          (o) => o.nomUnidade.toLowerCase().trim().startsWith('x'));
    }
    if (sort) {
      results.sort((a, b) => a.nomUnidade.compareTo(b.nomUnidade));
    }

    return results;
  }

  Future<void> insert(Unidade item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

    // verifica se ja existe
    //select nom_unidade as total from administracao.unidade where lower(nom_unidade) = lower('aa unidade teste')  and cod_orgao = 1 and ano_exercicio = '2023'
    final isExist = await conn
        .table(Unidade.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_unidade,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomOrgao])
        .where('cod_orgao', '=', item.codOrgao)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    if (isExist != null) {
      throw Exception('Já existe uma Unidade com este nome');
    }

    // pega codigo anterior
    // select max(cod_unidade) as ultima from administracao.unidade where cod_orgao=1 And ano_exercicio = '2023'
    final lastId = await conn
        .table('administracao.unidade')
        .selectRaw('''MAX(cod_unidade) AS codigo''')
        .where('cod_orgao', '=', item.codOrgao)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    final nextId = lastId == null || lastId['codigo'] == null
        ? 1
        : (lastId['codigo'] as int) + 1;

    item.codUnidade = nextId;

    // grava
    await conn.table(Unidade.fqtn).insert(item.toInsertMap());
  }

  Future<void> update(Unidade item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
// verifica se ja existe
//select nom_unidade as total from administracao.unidade where lower(nom_unidade) = lower('aa unidade teste 2') and cod_orgao = 1 and cod_unidade <> 1 and ano_exercicio = '2023'
    final isExist = await conn
        .table(Unidade.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_unidade,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomOrgao])
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '<>', item.codUnidade)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    if (isExist != null) {
      throw Exception('Já existe uma Unidade com este nome');
    }
    // UPDATE administracao.unidade SET nom_unidade  = 'aa unidade teste 2', usuario_responsavel='0' WHERE cod_unidade = 1 AND cod_orgao = 1 AND ano_exercicio =2023;
    await conn
        .table(Unidade.fqtn)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_orgao', '=', item.codOrgao)
        .where('ano_exercicio', '=', item.anoExercicio)
        .update(item.toUpdateMap());
  }

  Future<void> delete(Unidade item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    //  // select nom_unidade from administracao.unidade where cod_orgao = '1' and cod_unidade = '1' and ano_exercicio = '2023'
    // DELETE FROM administracao.unidade WHERE cod_orgao = 1 AND cod_unidade = 1 AND ano_exercicio = 2023;
    await conn
        .table('administracao.unidade')
        .from('administracao.unidade')
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('ano_exercicio', '=', item.anoExercicio)
        .delete();
  }
}
