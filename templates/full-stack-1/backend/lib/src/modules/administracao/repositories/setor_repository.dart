import 'package:eloquent/eloquent.dart';
import 'package:new_sali_core/new_sali_core.dart';

class SetorRepository {
  /// Conexão com o bamco de dados
  final Connection db;

  SetorRepository(this.db);

  /// lista todos os setores
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    final query = db.table('administracao.setor');
    query.selectRaw('''setor.*,  
      orgao.nom_orgao,
      unidade.nom_unidade,
      departamento.nom_departamento    
    ''');

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

    query.join('administracao.orgao AS orgao', (JoinClause jc) {
      jc.on('orgao.cod_orgao', '=', 'setor.cod_orgao');
      jc.on('orgao.ano_exercicio', '=', 'setor.ano_exercicio');
    }, null, null, 'inner');

    query.join('administracao.unidade AS unidade', (JoinClause jc) {
      jc.on('unidade.cod_orgao', '=', 'setor.cod_orgao');
      jc.on('unidade.cod_unidade', '=', 'setor.cod_unidade');
      jc.on('unidade.ano_exercicio', '=', 'setor.ano_exercicio');
    }, null, null, 'inner');

    query.join('administracao.departamento AS departamento', (JoinClause jc) {
      jc.on('departamento.cod_orgao', '=', 'setor.cod_orgao');
      jc.on('departamento.cod_unidade', '=', 'setor.cod_unidade');
      jc.on('departamento.cod_departamento', '=', 'setor.cod_departamento');
      jc.on('departamento.ano_exercicio', '=', 'setor.ano_exercicio');
    }, null, null, 'inner');

    // print('SetorRepository all');
    if (filtros?.codOrgao != null) {
      query.where('setor.cod_orgao', '=', filtros!.codOrgao);
    }
    if (filtros?.codUnidade != null) {
      query.where('setor.cod_unidade', '=', filtros!.codUnidade);
    }
    if (filtros?.codDepartamento != null) {
      query.where('setor.cod_departamento', '=', filtros!.codDepartamento);
    }
    if (filtros?.anoExercicio != null) {
      query.where('setor.ano_exercicio', '=', filtros!.anoExercicio);
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      query.orderByRaw(
          'lower(orgao.nom_orgao), lower(unidade.nom_unidade), lower(departamento.nom_departamento), lower(setor.nom_setor) ');
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

  Future<List<Setor>> getAllSetor(
      {int? codOrgao,
      int? codUnidade,
      int? codDepartamento,
      String? anoExercicio,
      bool removeDisabled = false,
      bool sort = true}) async {
    final query = db.table('administracao.setor');
    if (codOrgao != null) {
      query.where('setor.cod_orgao', '=', codOrgao);
    }
    if (codUnidade != null) {
      query.where('setor.cod_unidade', '=', codUnidade);
    }
    if (codDepartamento != null) {
      query.where('setor.cod_departamento', '=', codDepartamento);
    }
    if (anoExercicio != null) {
      query.where('setor.ano_exercicio', '=', anoExercicio);
    }
    final dados = await query.get();

    final results = dados.map((e) => Setor.fromMap(e)).toList();

    if (removeDisabled) {
      results
          .removeWhere((o) => o.nomSetor.toLowerCase().trim().startsWith('x'));
      results.removeWhere((o) => o.situacao == '0');
    }

    if (sort) {
      results.sort((a, b) => a.nomSetor.compareTo(b.nomSetor));
    }
    return results;
  }

  Future<void> insert(Setor item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;

// verifica se ja existe
//  select nom_setor as total from administracao.setor where lower(nom_setor) = lower('aa Setor teste') and cod_orgao = 01 and cod_unidade = 001 and cod_departamento = 001 and ano_exercicio='2023'
    final isExist = await conn
        .table(Setor.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_setor,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomOrgao])
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_departamento', '=', item.codDepartamento)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    if (isExist != null) {
      throw Exception('Já existe um Setor com este nome');
    }

    // pega codigo anterior
// select max(cod_setor) as ultima from administracao.setor Where cod_orgao = '01'  And cod_unidade = '001'  And cod_departamento = '001' And ano_exercicio = '2023'
    final lastId = await conn
        .table('administracao.setor')
        .selectRaw('''MAX(cod_setor) AS codigo''')
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_departamento', '=', item.codDepartamento)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    final nextId = lastId == null || lastId['codigo'] == null
        ? 1
        : (lastId['codigo'] as int) + 1;

    item.codSetor = nextId;

    // grava
// INSERT INTO administracao.setor (cod_setor, cod_departamento, cod_unidade, cod_orgao, nom_setor, ano_exercicio, usuario_responsavel, situacao) VALUES ('1','001','001','01','aa Setor teste','2023','0','1');
    await conn.table(Setor.fqtn).insert(item.toInsertMap());
  }

  Future<void> update(Setor item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
    // verifica se ja existe
// select nom_Setor as total from administracao.setor where lower(nom_Setor) = lower('aa Setor teste atualizado') and cod_orgao = 1 and cod_unidade = 1 and cod_departamento = 1 and cod_setor <> 1
    final isExist = await conn
        .table(Setor.fqtn)
        .whereRaw(
            '''LOWER(TO_ASCII(nom_setor,'LATIN_1')) = LOWER(TO_ASCII( ? ,'LATIN_1')) ''',
            [item.nomOrgao])
        .where('cod_setor', '<>', item.codSetor)
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_departamento', '=', item.codDepartamento)
        .where('ano_exercicio', '=', item.anoExercicio)
        .first();

    if (isExist != null) {
      throw Exception('Já existe um Setor com este nome');
    }
    // UPDATE administracao.setor SET nom_setor  = 'aa Setor teste atualizado', usuario_responsavel='0',situacao='1' WHERE cod_setor = 1 AND cod_departamento = 1 AND cod_unidade = 1 AND cod_orgao = 1 AND ano_exercicio =2023;
    await conn
        .table(Setor.fqtn)
        .where('cod_setor', '=', item.codSetor)
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_departamento', '=', item.codDepartamento)
        .where('ano_exercicio', '=', item.anoExercicio)
        .update(item.toUpdateMap());
  }

  Future<void> delete(Setor item, {Connection? connection}) async {
    final conn = connection != null ? connection : db;
//  select nom_setor from administracao.setor where cod_orgao='1' and cod_unidade='1' and cod_departamento='1' and cod_setor='1' and ano_exercicio = '2023'
// DELETE FROM administracao.setor WHERE cod_setor = 1 AND cod_departamento = 1 AND cod_unidade = 1 AND cod_orgao = 1 AND ano_exercicio =2023;
    await conn
        .table('administracao.setor')
        .from('administracao.setor')
        .where('cod_setor', '=', item.codSetor)
        .where('cod_orgao', '=', item.codOrgao)
        .where('cod_unidade', '=', item.codUnidade)
        .where('cod_departamento', '=', item.codDepartamento)
        .where('ano_exercicio', '=', item.anoExercicio)
        .delete();
  }
}
