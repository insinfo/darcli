import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class OrgaoRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  OrgaoRepository(this.db);

  /// lista todos os Orgãos
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    final query = db.table('administracao.orgao');

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

    // if (filtros?.anoExercicio != null) {
    //   query.where('ano_exercicio', '=', filtros!.anoExercicio);
    // }

    if (filtros?.codOrgao != null && filtros?.codOrgao != -1) {
      query.where('cod_orgao', '=', filtros!.codOrgao);
    } else {
      query.whereRaw('cod_orgao > 0');
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
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

  Future<List<Orgao>> getAllOrgao(
      {bool removeDisabled = false, bool sort = true}) async {
    final query = db.table('administracao.orgao');
    query.orWhereRaw('cod_orgao > 0');

    final dados = await query.get();
    final results = dados.map((e) => Orgao.fromMap(e)).toList();

    //orgao.nomOrgao.trim().toLowerCase().startsWith('x')

    if (removeDisabled) {
      results
          .removeWhere((o) => o.nomOrgao.toLowerCase().trim().startsWith('x'));
    }

    if (sort) {
      results.sort((a, b) => a.nomOrgao.compareTo(b.nomOrgao));
    }

    return results;
  }

  Future<void> insert(Orgao item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

    // verifica se ja existe
    //select nom_orgao as total from administracao.orgao where lower(nom_orgao) = lower('teste orgao') And ano_exercicio = '2023'
    final isExist = await conn
        .table(Orgao.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_orgao,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomOrgao])
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    if (isExist != null) {
      throw Exception('Já existe um Orgão com este nome');
    }

    // pega codigo anterior
    // select max(cod_orgao) as ultima from administracao.orgao Where ano_exercicio = '2023'
    final lastId = await conn
        .table('administracao.orgao')
        .selectRaw('''MAX(cod_orgao) AS codigo''')
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    final nextId = lastId == null || lastId['codigo'] == null
        ? 1
        : (lastId['codigo'] as int) + 1;
        

    item.codOrgao = nextId;

    // grava
    await conn.table(Orgao.fqtn).insert(item.toInsertMap());
  }

  Future<void> update(Orgao item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    // verifica se ja existe
    //select nom_orgao as total from administracao.orgao where lower(nom_orgao) = lower('teste orgao auterado') and cod_orgao <> 1 and ano_exercicio = 2023
    final isExist = await conn
        .table(Orgao.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_orgao,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomOrgao])
        .where('cod_orgao', '<>', item.codOrgao)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    if (isExist != null) {
      throw Exception('Já existe um Orgão com este nome');
    }
    //UPDATE administracao.orgao SET nom_orgao = 'teste orgao auterado', usuario_responsavel='10400' WHERE cod_orgao = 1 AND ano_exercicio = 2023;
    await conn
        .table(Orgao.fqtn)
        .where('cod_orgao', '=', item.codOrgao)
        .where('ano_exercicio', '=', item.anoExercicio)
        .update(item.toUpdateMap());
  }

  Future<void> delete(Orgao item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

//  select nom_orgao from administracao.orgao where cod_orgao = '1' and ano_exercicio = '2023'
//  BEGIN;
//          DELETE FROM administracao.orgao WHERE cod_orgao = 1 AND ano_exercicio = 2023;
//          COMMIT;
//  BEGIN;
//          INSERT INTO administracao.auditoria (numcgm, cod_acao, objeto) VALUES ('140050', '4', '01/2023 - teste orgao auterado'); ;
//          COMMIT;

    await conn
        .table('administracao.orgao')
        .from('administracao.orgao')
        .where('cod_orgao', '=', item.codOrgao)
        .where('ano_exercicio', '=', item.anoExercicio)
        .delete();
  }
}
