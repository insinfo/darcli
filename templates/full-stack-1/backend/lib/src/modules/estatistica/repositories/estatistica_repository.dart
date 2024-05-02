import 'package:eloquent/eloquent.dart';

import 'package:new_sali_core/new_sali_core.dart';

class EstatisticaRepository {
  final Connection db;

  EstatisticaRepository(this.db);

  /// lista o total de Processos por ano desde 20 anos atras a partir do ano atual
  Future<List<Map<String, dynamic>>> totalProcessosPorAno(
      {Filters? filtros}) async {
    final year = DateTime.now().year - 20;

    var query = db.table('public.sw_processo');
    query.selectRaw('''
count(sw_processo.cod_processo) as total, 
sw_processo.ano_exercicio 
''');
    //sw_processo.ano_exercicio::int > (date_part('year', current_date)::int -20)
    //pega ultimo andamento
    if (filtros != null && filtros.codOrgao != null) {
      query.join('sw_ultimo_andamento AS ultimo_andamento', (JoinClause jc) {
        jc.on(
            'sw_processo.ano_exercicio', '=', 'ultimo_andamento.ano_exercicio');
        jc.on('sw_processo.cod_processo', '=', 'ultimo_andamento.cod_processo');
      });
    }
    query.whereRaw(''' sw_processo.ano_exercicio::int > '$year' ''');
    if (filtros != null && filtros.codOrgao != null) {
      query.where('ultimo_andamento.cod_orgao', '=', filtros.codOrgao);
      query.where('ultimo_andamento.cod_unidade', '=', filtros.codUnidade);
      query.where(
          'ultimo_andamento.cod_departamento', '=', filtros.codDepartamento);
      query.where('ultimo_andamento.cod_setor', '=', filtros.codSetor);
      query.where(
          'ultimo_andamento.ano_exercicio_setor', '=', filtros.anoExercicio);
    }

    query.groupBy(['sw_processo.ano_exercicio']);
    query.orderByRaw('2 desc');
    var dados = await query.get();
    return dados;
  }

  /// total de processos por periodo e setor destino do primero tramite
  Future<List<Map<String, dynamic>>> processByPeriodoSetorPrimeroTramite(
      {Filters? filtros}) async {
    var query = db.table('public.sw_processo');
    query.selectRaw('count(sw_processo.cod_processo) as total,setor.nom_setor');

    //pega primeiro andamento
    query.join('public.sw_andamento', (JoinClause jc) {
      jc.on('sw_processo.cod_processo', '=', 'sw_andamento.cod_processo');
      jc.on('sw_processo.ano_exercicio', '=', 'sw_andamento.ano_exercicio');
      jc.on('sw_andamento.cod_andamento', '=', db.raw('1'));
    });
    //pega setor
    query.join('administracao.setor', (JoinClause jc) {
      jc.on('setor.cod_orgao', '=', 'sw_andamento.cod_orgao');
      jc.on('setor.cod_unidade', '=', 'sw_andamento.cod_unidade');
      jc.on('setor.cod_departamento', '=', 'sw_andamento.cod_departamento');
      jc.on('setor.cod_setor', '=', 'sw_andamento.cod_setor');
      jc.on('setor.ano_exercicio', '=', 'sw_andamento.ano_exercicio_setor');
    });

    if (filtros != null && filtros.codOrgao != null) {
      query.where('sw_andamento.cod_orgao', '=', filtros.codOrgao);
      query.where('sw_andamento.cod_unidade', '=', filtros.codUnidade);
      query.where(
          'sw_andamento.cod_departamento', '=', filtros.codDepartamento);
      query.where('sw_andamento.cod_setor', '=', filtros.codSetor);
      query.where(
          'sw_andamento.ano_exercicio_setor', '=', filtros.anoExercicio);
    }
    final now = DateTime.now();
    final initDate =filtros?.inicio ?? DateTime(now.year, now.month, 1);
    final lastDate =filtros?.fim ?? DateTime(now.year, now.month + 1, 0);

    query.whereBetween('sw_processo.timestamp',
        [initDate.toIso8601String(), lastDate.toIso8601String()]);
    query.groupBy([
      'sw_andamento.cod_orgao',
      'sw_andamento.cod_unidade',
      'sw_andamento.cod_departamento',
      'sw_andamento.cod_setor',
      'sw_andamento.ano_exercicio_setor',
      'setor.nom_setor'
    ]);
    // query.orderByRaw('2 asc');
    var dados = await query.get();
    return dados;
  }

  Future<List<Map<String, dynamic>>> processosPorSituacao(
      {Filters? filtros}) async {
    final year = filtros?.anoExercicio ?? DateTime.now().year.toString();

    var query = db.table('public.sw_processo');
    query.selectRaw('''
count(sw_processo.cod_processo) AS total,
	sw_processo.cod_situacao 
	,sw_situacao_processo.nom_situacao
''');
    query.join('sw_situacao_processo', 'sw_situacao_processo.cod_situacao', '=',
        'sw_processo.cod_situacao');

    if (filtros != null && filtros.codOrgao != null) {
      query.join('sw_ultimo_andamento AS ultimo_andamento', (JoinClause jc) {
        jc.on(
            'sw_processo.ano_exercicio', '=', 'ultimo_andamento.ano_exercicio');
        jc.on('sw_processo.cod_processo', '=', 'ultimo_andamento.cod_processo');
      });
    }

    query.whereRaw(''' sw_processo.ano_exercicio = ? ''', [year]);

    if (filtros != null && filtros.codOrgao != null) {
      query.where('ultimo_andamento.cod_orgao', '=', filtros.codOrgao);
      query.where('ultimo_andamento.cod_unidade', '=', filtros.codUnidade);
      query.where(
          'ultimo_andamento.cod_departamento', '=', filtros.codDepartamento);
      query.where('ultimo_andamento.cod_setor', '=', filtros.codSetor);
      query.where(
          'ultimo_andamento.ano_exercicio_setor', '=', filtros.anoExercicio);
    }

    query.groupBy([
      'sw_processo.cod_situacao',
      'sw_situacao_processo.nom_situacao',
    ]);
    query.orderByRaw('sw_processo.cod_situacao asc');
    var dados = await query.get();
    return dados;
  }

  Future<List<Map<String, dynamic>>> totalProcessosPorClassificacao(
      {Filters? filtros}) async {
    final year = filtros?.anoExercicio ?? DateTime.now().year.toString();

    var query = db.table('public.sw_processo');
    query.selectRaw('''
count(sw_processo.cod_processo) AS total,
lower(sw_classificacao.nom_classificacao) AS nom_classificacao
''');
    query.join('public.sw_classificacao', (JoinClause jc) {
      jc.on('sw_classificacao.cod_classificacao', '=',
          'sw_processo.cod_classificacao');
    });

    //  query.join('public.sw_assunto', (JoinClause jc) {
    //   jc.on('sw_assunto.cod_classificacao','=','sw_processo.cod_classificacao');
    //   jc.on('sw_assunto.cod_assunto','=','sw_processo.cod_assunto');
    // });

    //pega ultimo andamento
    if (filtros != null && filtros.codOrgao != null) {
      query.join('sw_ultimo_andamento AS ultimo_andamento', (JoinClause jc) {
        jc.on(
            'sw_processo.ano_exercicio', '=', 'ultimo_andamento.ano_exercicio');
        jc.on('sw_processo.cod_processo', '=', 'ultimo_andamento.cod_processo');
      });
    }
    query.whereRaw(''' sw_processo.ano_exercicio = '$year' ''');

    if (filtros != null && filtros.codOrgao != null) {
      query.where('ultimo_andamento.cod_orgao', '=', filtros.codOrgao);
      query.where('ultimo_andamento.cod_unidade', '=', filtros.codUnidade);
      query.where(
          'ultimo_andamento.cod_departamento', '=', filtros.codDepartamento);
      query.where('ultimo_andamento.cod_setor', '=', filtros.codSetor);
      query.where(
          'ultimo_andamento.ano_exercicio_setor', '=', filtros.anoExercicio);
    }

    query.groupBy(['sw_classificacao.nom_classificacao']);
    query.orderByRaw('2 asc');
    var dados = await query.get();
    return dados;
  }

  Future<List<Map<String, dynamic>>> totalProcessosPorAssunto(
      {Filters? filtros}) async {
    final year = filtros?.anoExercicio ?? DateTime.now().year.toString();

    var query = db.table('public.sw_processo');
    query.selectRaw('''
count(sw_processo.cod_processo) AS total,
lower(sw_assunto.nom_assunto) as nom_assunto
''');

    query.join('public.sw_assunto', (JoinClause jc) {
      jc.on(
          'sw_assunto.cod_classificacao', '=', 'sw_processo.cod_classificacao');
      jc.on('sw_assunto.cod_assunto', '=', 'sw_processo.cod_assunto');
    });

    //pega ultimo andamento
    if (filtros != null && filtros.codOrgao != null) {
      query.join('sw_ultimo_andamento AS ultimo_andamento', (JoinClause jc) {
        jc.on(
            'sw_processo.ano_exercicio', '=', 'ultimo_andamento.ano_exercicio');
        jc.on('sw_processo.cod_processo', '=', 'ultimo_andamento.cod_processo');
      });
    }
    query.whereRaw(''' sw_processo.ano_exercicio = '$year' ''');

    if (filtros != null && filtros.codOrgao != null) {
      query.where('ultimo_andamento.cod_orgao', '=', filtros.codOrgao);
      query.where('ultimo_andamento.cod_unidade', '=', filtros.codUnidade);
      query.where(
          'ultimo_andamento.cod_departamento', '=', filtros.codDepartamento);
      query.where('ultimo_andamento.cod_setor', '=', filtros.codSetor);
      query.where(
          'ultimo_andamento.ano_exercicio_setor', '=', filtros.anoExercicio);
    }

    query.groupBy(['sw_assunto.nom_assunto']);
    query.orderByRaw('2 asc');
    var dados = await query.get();
    return dados;
  }
}
