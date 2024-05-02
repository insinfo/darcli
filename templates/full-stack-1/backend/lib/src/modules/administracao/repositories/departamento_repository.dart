import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class DepartamentoRepository {
  final Connection db;

  DepartamentoRepository(this.db);

  /// lista todos os departamentos
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    final query = db.table('administracao.departamento');
    query.selectRaw(
        '''departamento.*, orgao.nom_orgao , unidade.nom_unidade ''');

    query.join('administracao.orgao', (JoinClause jc) {
      jc.on('orgao.cod_orgao', '=', 'departamento.cod_orgao');
      jc.on('orgao.ano_exercicio', '=', 'departamento.ano_exercicio');
    });

    query.join('administracao.unidade', (JoinClause jc) {
      jc.on('unidade.cod_unidade', '=', 'departamento.cod_unidade');
      jc.on('unidade.cod_orgao', '=', 'departamento.cod_orgao');
      jc.on('unidade.ano_exercicio', '=', 'departamento.ano_exercicio');
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
      query.where('departamento.cod_orgao', '=', filtros!.codOrgao);
    }
    if (filtros?.codUnidade != null) {
      query.where('departamento.cod_unidade', '=', filtros!.codUnidade);
    }
    if (filtros?.anoExercicio != null) {
      query.where('departamento.ano_exercicio', '=', filtros!.anoExercicio);
    }

    if (filtros?.situacao != null) {
      query.where('departamento.situacao', '=', filtros!.situacao);
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      query.orderByRaw(
          ''' lower(orgao.nom_orgao), lower(unidade.nom_unidade), lower(departamento.nom_departamento) ASC ''');
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

  Future<List<Departamento>> getAllDepartamento(
      {int? codOrgao,
      int? codUnidade,
      String? anoExercicio,
      bool removeDisabled = false,
      bool sort = true}) async {
    final query = db.table('administracao.departamento');
    if (codOrgao != null) {
      query.where('cod_orgao', '=', codOrgao);
    }
    if (codUnidade != null) {
      query.where('cod_unidade', '=', codUnidade);
    }
    if (anoExercicio != null) {
      query.where('ano_exercicio', '=', anoExercicio);
    }
    final dados = await query.get();
    final results = dados.map((e) => Departamento.fromMap(e)).toList();

    if (removeDisabled) {
      results.removeWhere(
          (o) => o.nomDepartamento.toLowerCase().trim().startsWith('x'));
    }
    if (sort) {
      results.sort((a, b) => a.nomDepartamento.compareTo(b.nomDepartamento));
    }

    return results;
  }

  Future<void> insert(Departamento item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

// verifica se ja existe
//  select nom_departamento as total from administracao.departamento where lower(nom_departamento) = lower('aa departamento teste') and cod_orgao = 01 and cod_unidade = 001 and ano_exercicio='2023'
    final isExist = await conn
        .table(Departamento.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_departamento,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomOrgao])
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    if (isExist != null) {
      throw Exception('Já existe um Departamento com este nome');
    }

    // pega codigo anterior
    // select max(cod_departamento) as ultima from administracao.departamento where cod_orgao='01' and cod_unidade='001' and ano_exercicio='2023'
    final lastId = await conn
        .table('administracao.departamento')
        .selectRaw('''MAX(cod_departamento) AS codigo''')
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    final nextId = lastId == null || lastId['codigo'] == null
        ? 1
        : (lastId['codigo'] as int) + 1;

    item.codDepartamento = nextId;

    // grava
    await conn.table(Departamento.fqtn).insert(item.toInsertMap());
  }

  Future<void> update(Departamento item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
// verifica se ja existe
// select nom_departamento as total from administracao.departamento where lower(nom_departamento) = lower('aa departamento teste atualizado')
// AND cod_orgao = 1 AND cod_unidade = 1 AND cod_departamento <> 1 AND ano_exercicio='2023'
    final isExist = await conn
        .table(Departamento.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_departamento,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomOrgao])
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_departamento', '<>', item.codDepartamento)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    if (isExist != null) {
      throw Exception('Já existe um Departamento com este nome');
    }

    // UPDATE administracao.departamento SET nom_departamento  = 'aa departamento teste atualizado', usuario_responsavel='0'
    // WHERE cod_departamento = 1 AND cod_unidade = 1  AND cod_orgao = 1  AND ano_exercicio =2023;
    await conn
        .table(Departamento.fqtn)
        .where('cod_departamento', '=', item.codDepartamento)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_orgao', '=', item.codOrgao)
        .where('ano_exercicio', '=', item.anoExercicio)
        .update(item.toUpdateMap());
  }

  Future<void> delete(Departamento item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
// select nom_departamento from administracao.departamento where cod_orgao = '1' and cod_unidade = '1' and cod_departamento = '1' and ano_exercicio = '2023'
// DELETE FROM administracao.departamento WHERE cod_departamento = 1 AND cod_unidade = 1 AND cod_orgao = 1 AND ano_exercicio =2023;
    await conn
        .table('administracao.departamento')
        .from('administracao.departamento')
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_departamento', '=', item.codDepartamento)
        .where('ano_exercicio', '=', item.anoExercicio)
        .delete();
  }
}
