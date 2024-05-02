import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class VagaRepository {
  final Connection db;
  VagaRepository(this.db);

  /// lista todas as vagas
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Vaga.fqtn).selectRaw('''
vagas.*, 
empregadores.contato AS "empregadorContato", 
cargos.nome AS "cargoNome", 
pessoas.nome AS "empregadorNome",
escolaridades.nome AS "grauEscolaridade",
escolaridades."ordemGraduacao"
  ''');
    query.join(
        Empregador.fqtn, 'empregadores.idPessoa', '=', 'vagas.idEmpregador');
    query.join(Cargo.fqtn, 'cargos.id', '=', 'vagas.idCargo');
    query.join(Pessoa.fqtn, 'pessoas.id', '=', 'vagas.idEmpregador');
    query.join(
        Escolaridade.fqtn, 'escolaridades.id', '=', 'vagas.idEscolaridade');

    if (filtros?.idEmpregador != null) {
      query.where('vagas.idEmpregador', '=', filtros!.idEmpregador);
    }
    if (filtros?.idCargo != null) {
      query.where('vagas.idCargo', '=', filtros!.idCargo);
    }

    if (filtros?.bloqueioEncaminhamento != null) {
      query.where(
          'vagas.bloqueioEncaminhamento', '=', filtros!.bloqueioEncaminhamento);
    }
    if (filtros?.isValidado != null) {
      query.where('vagas.validado', '=', filtros!.isValidado);
    }

    if (filtros?.searchString != null && filtros?.searchString?.trim() != '') {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString!.toLowerCase()}%';
            query.whereRaw(
                ''' LOWER(unaccent(${sField.field})) like unaccent( ? ) ''',
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
      if (totalRecords > 1) {
        query.orderBy('vagas.bloqueioEncaminhamento', 'asc');
        query.orderBy('escolaridades.ordemGraduacao', 'asc');
      }
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    final dados = await query.get();

    if (dados.isNotEmpty == true) {
      final idsEmpregador = dados.map((e) => e['idEmpregador'] as int).toList();
      // pega empregadores
      final empregadores = await db
          .table(Empregador.fqtn)
          .selectRaw('empregadores.*, pessoas.* ')
          .join(Pessoa.fqtn, 'pessoas.id', '=', 'empregadores.idPessoa')
          .whereIn('idPessoa', idsEmpregador)
          .get();

      for (var i = 0; i < dados.length; i++) {
        var item = dados[i];
        // pega empregador
        final empregador = empregadores
            .where((e) => e['idPessoa'] == item['idEmpregador'])
            .first;

        dados[i]['empregador'] = empregador;
      }
    }

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  /// lista as vagas para o site da PMRO/Portal Banco de Empregos
  Future<DataFrame<Map<String, dynamic>>> getAllForSite(
      {Filters? filtros}) async {
    final query = db.table(Vaga.fqtn).selectRaw('''
vagas.*, 
cargos.nome AS "cargoNome", 
pessoas.nome AS "empregadorNome",
escolaridades.nome AS "grauEscolaridade",
escolaridades."ordemGraduacao"
  ''');
    query.join(
        Empregador.fqtn, 'empregadores.idPessoa', '=', 'vagas.idEmpregador');
    query.join(Cargo.fqtn, 'cargos.id', '=', 'vagas.idCargo');
    query.join(Pessoa.fqtn, 'pessoas.id', '=', 'vagas.idEmpregador');
    query.join(
        Escolaridade.fqtn, 'escolaridades.id', '=', 'vagas.idEscolaridade');

    if (filtros?.idEmpregador != null) {
      query.where('vagas.idEmpregador', '=', filtros!.idEmpregador);
    } else {
      query.where('vagas.bloqueioEncaminhamento', '=', false);
      query.where('vagas.validado', '=', true);
    }

    if (filtros?.cpfCandidato != null) {
      final candidato =
          await CandidatoRepository(db).getByCpf(filtros!.cpfCandidato!);

      //filtra por cargo
      query.whereIn(
          'vagas.idCargo', candidato.cargosDesejados.map((c) => c.id).toList());

      print(
          'VagaRepository@getAllForSite candidato.ordemGraduacao ${candidato.ordemGraduacao}');
      //filtra por escolaridade ordemGraduacao
      query.whereRaw(
          ''' '${candidato.ordemGraduacao}'  >= escolaridades."ordemGraduacao" ''');
    }

    if (filtros?.idCargo != null) {
      query.where('vagas.idCargo', '=', filtros!.idCargo);
    }

    if (filtros?.searchString != null && filtros?.searchString?.trim() != '') {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString!.toLowerCase()}%';
            query.whereRaw(
                ''' LOWER(unaccent(${sField.field})) like unaccent( ? ) ''',
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
      if (totalRecords > 1) {
        //query.orderBy('idPessoa');
      }
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

  /// lista todos os bloqueios de encaminhamento de uma vaga
  Future<DataFrame<Map<String, dynamic>>> getAllBloqueiosEncaminhamento(
      int idVaga,
      {Filters? filtros}) async {
    final query = db.table(BloqueioEncaminhamento.fqtn);

    query.selectRaw(
        ''' ${BloqueioEncaminhamento.tableName}.*, ${Pessoa.nomeFqCol} as "usuarioResponsavel" ''');

    query.leftJoin(Pessoa.fqtn, Pessoa.idFqCol, '=',
        BloqueioEncaminhamento.idUsuarioResponsavelFqCol);

    query.where(BloqueioEncaminhamento.idVagaCol, '=', idVaga);

    if (filtros?.searchString != null && filtros?.searchString?.trim() != '') {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString!.toLowerCase()}%';
            query.whereRaw(
                ''' LOWER(unaccent(${sField.field})) like unaccent( ? ) ''',
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
      if (totalRecords > 1) {
        query.orderBy(BloqueioEncaminhamento.dataCol);
      }
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

  /// obtem vaga completa com cargo, cursos etc
  Future<Vaga> getById(int idVaga) async {
    final map = await getByIdAsMap(idVaga);
    return Vaga.fromMap(map);
  }

  /// obtem vaga completa com cargo, cursos etc
  Future<Map<String, dynamic>> getByIdAsMap(int idVaga) async {
    final query = db.table(Vaga.fqtn).selectRaw('''
vagas.*, 
empregadores.contato AS "empregadorContato", 
cargos.nome AS "cargoNome", 
pessoas.nome AS "empregadorNome",
escolaridades.nome AS "grauEscolaridade",
escolaridades."ordemGraduacao"
  ''');
    query.join(
        Empregador.fqtn, 'empregadores.idPessoa', '=', 'vagas.idEmpregador');
    query.join(Cargo.fqtn, 'cargos.id', '=', 'vagas.idCargo');
    query.join(Pessoa.fqtn, 'pessoas.id', '=', 'vagas.idEmpregador');
    query.join(
        Escolaridade.fqtn, 'escolaridades.id', '=', 'vagas.idEscolaridade');

    query.where('vagas.id', '=', idVaga);

    final data = await query.first();

    if (data == null) {
      throw Exception('Não encontrado com o id = $idVaga');
    }

    //Obter Beneficios
    final dadosBeneficios = await db
        .table(VagaBeneficio.fqtn)
        .selectRaw('*')
        .where('vagas_beneficios.idVaga', '=', idVaga)
        .get();

    data['beneficios'] = dadosBeneficios;

    //Obter cursos
    final dadosCurso = await db
        .table(VagaCurso.fqtn)
        .selectRaw('cursos.*, vagas_cursos."idVaga", vagas_cursos.obrigatorio')
        .join(Curso.fqtn, 'cursos.id', '=', 'vagas_cursos.idCurso')
        .where('vagas_cursos.idVaga', '=', idVaga)
        .get();

    data['cursos'] = dadosCurso;

    //Obter conhecimento extra
    final dadosConhecimentosExtra = await db
        .table(VagaConhecimentoExtra.fqtn)
        .selectRaw('''conhecimentos_extras.*, 
            vagas_conhecimentos_extras."idVaga", 
            vagas_conhecimentos_extras.obrigatorio, 
            tipos_conhecimentos.nome as "tipoConhecimentoExtraNome"
            ''')
        .join(ConhecimentoExtra.fqtn, 'conhecimentos_extras.id', '=',
            'vagas_conhecimentos_extras.idConhecimentoExtra')
        .join(TipoConhecimento.fqtn, 'tipos_conhecimentos.id', '=',
            'conhecimentos_extras.idTipoConhecimento')
        .where('vagas_conhecimentos_extras.idVaga', '=', idVaga)
        .get();

    data['conhecimentosExtras'] = dadosConhecimentosExtra;

    if (data['bloqueioEncaminhamento'].toString() == 'true') {
      final blockEncaminhamento = await db
          .table(BloqueioEncaminhamento.fqtn)
          .selectRaw('bloqueios_encaminhamentos.*')
          .where('bloqueios_encaminhamentos.idVaga', '=', idVaga)
          .orderBy('id', 'desc')
          .first();
      data['bloqueioEncaminhamentoInstance'] = blockEncaminhamento;
    }

    final userResp = await db
        .table(Pessoa.fqtn)
        .selectRaw('nome')
        .where('pessoas.id', '=', data['idUsuarioResponsavel'])
        .first();

    if (userResp != null) {
      data['usuarioResponsavelNome'] = userResp['nome'];
    }

    return data;
  }

  Future<void> createInTransaction(int idUsuarioLogado, Vaga vaga) async {
    await db.transaction((ctx) async {
      await create(idUsuarioLogado, vaga, connection: ctx);
    });
  }

  Future<void> create(int idUsuarioLogado, Vaga vaga,
      {Connection? connection}) async {
    final conn = connection ?? db;

    vaga.idUsuarioResponsavel = idUsuarioLogado;

    final idVaga = await conn.table(Vaga.fqtn).insertGetId(vaga.toInsertMap());

    print(
        'VagaRepository@incluir idVaga = $idVaga | idUsuarioResponsavel $idUsuarioLogado');

    if (vaga.beneficios.isNotEmpty == true) {
      for (final bene in vaga.beneficios) {
        bene.idVaga = idVaga;
        await conn.table(Beneficio.fqtn).insert(bene.toInsertMap());
      }
    }

    if (vaga.cursos.isNotEmpty == true) {
      for (final cur in vaga.cursos) {
        cur.idVaga = idVaga;
        await conn.table(VagaCurso.fqtn).insert(cur.toInsertVagaCurso());
      }

      if (vaga.conhecimentosExtras.isNotEmpty == true) {
        for (final conExtra in vaga.conhecimentosExtras) {
          conExtra.idVaga = idVaga;
          await conn
              .table(VagaConhecimentoExtra.fqtn)
              .insert(conExtra.toInsertVagaConhecimentoExtra());
        }
      }
    }
  }

  Future<void> updateInTransaction(int idUsuarioLogado, Vaga vaga) async {
    await db.transaction((ctx) async {
      await update(idUsuarioLogado, vaga, connection: ctx);
    });
  }

  Future<void> update(int idUsuarioLogado, Vaga vaga,
      {Connection? connection}) async {
    final conn = connection ?? db;

    vaga.idUsuarioResponsavel = idUsuarioLogado;

    await conn
        .table(Vaga.fqtn)
        .where('id', '=', vaga.id)
        .update(vaga.toUpdateMap());

    await conn.table(VagaCurso.fqtn).where('idVaga', '=', vaga.id).delete();

    if (vaga.cursos.isNotEmpty == true) {
      for (final cur in vaga.cursos) {
        cur.idVaga = vaga.id;
        await conn.table(VagaCurso.fqtn).insert(cur.toInsertVagaCurso());
      }
    }

    await conn
        .table(VagaConhecimentoExtra.fqtn)
        .where('idVaga', '=', vaga.id)
        .delete();

    if (vaga.conhecimentosExtras.isNotEmpty == true) {
      for (final conExtra in vaga.conhecimentosExtras) {
        conExtra.idVaga = vaga.id;
        await conn
            .table(VagaConhecimentoExtra.fqtn)
            .insert(conExtra.toInsertVagaConhecimentoExtra());
      }
    }

    await conn.table(Beneficio.fqtn).where('idVaga', '=', vaga.id).delete();

    if (vaga.beneficios.isNotEmpty == true) {
      for (final bene in vaga.beneficios) {
        bene.idVaga = vaga.id;
        await conn.table(Beneficio.fqtn).insert(bene.toInsertMap());
      }
    }
  }

  Future<void> bloquearVaga(
      int idUsuarioLogado, BloqueioEncaminhamento bloqueioEncaminhamento,
      {Connection? connection}) async {
    final conn = connection ?? db;

    bloqueioEncaminhamento.data = DateTime.now();
    bloqueioEncaminhamento.idUsuarioResponsavel = idUsuarioLogado;

    await conn
        .table(BloqueioEncaminhamento.fqtn)
        .insert(bloqueioEncaminhamento.toInsertMap());

    await conn
        .table(Vaga.fqtn)
        .where(Vaga.idCol, '=', bloqueioEncaminhamento.idVaga)
        .update({Vaga.bloqueioEncaminhamentoCol: true});
  }

  Future<void> bloquearVagaInTransaction(int idUsuarioLogado,
      BloqueioEncaminhamento bloqueioEncaminhamento) async {
    await db.transaction((ctx) async {
      await bloquearVaga(idUsuarioLogado, bloqueioEncaminhamento,
          connection: ctx);
    });
  }

  /// rotina a ser chamada no Cron (Agendador de tarefa) para bloquear vagas que encerram
  Future<void> bloquearVagasVencidas() async {
    final vagasVencidas = await db
        .table(Vaga.fqtn)
        .whereRaw('now() > vagas."dataEncerramento"')
        .where('bloqueioEncaminhamento', '=', false)
        .get();

    for (var item in vagasVencidas) {
      var bloqueioEncaminhamento = BloqueioEncaminhamento(
        acao: TipoBloqueioEncaminhamento.bloqueioAutomatico,
        justificativa: 'Bloqueada automaticamente por data de Encerramento',
        idVaga: item['id'],
        data: DateTime.now(),
        idUsuarioResponsavel: 0,
      );
      await bloquearVaga(0, bloqueioEncaminhamento);
    }
  }

  Future<void> desbloquearVaga(
      int idUsuarioLogado, BloqueioEncaminhamento bloqueioEncaminhamento,
      {Connection? connection}) async {
    final conn = connection ?? db;

    bloqueioEncaminhamento.data = DateTime.now();
    bloqueioEncaminhamento.idUsuarioResponsavel = idUsuarioLogado;

    await conn
        .table(BloqueioEncaminhamento.fqtn)
        .insert(bloqueioEncaminhamento.toInsertMap());

    await conn
        .table(Vaga.fqtn)
        .where(Vaga.idCol, '=', bloqueioEncaminhamento.idVaga)
        .update({Vaga.bloqueioEncaminhamentoCol: false});
  }

  Future<void> validarVaga(int idVaga, {Connection? connection}) async {
    final conn = connection ?? db;

    await conn
        .table(Vaga.fqtn)
        .where(Vaga.idCol, '=', idVaga)
        .update({Vaga.validadoCol: true});
  }

  Future<void> desbloquearVagaInTransaction(int idUsuarioLogado,
      BloqueioEncaminhamento bloqueioEncaminhamento) async {
    await db.transaction((ctx) async {
      await desbloquearVaga(idUsuarioLogado, bloqueioEncaminhamento,
          connection: ctx);
    });
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;

    await conn.table(VagaCurso.fqtn).where('idVaga', '=', id).delete();

    await conn
        .table(VagaConhecimentoExtra.fqtn)
        .where('idVaga', '=', id)
        .delete();

    await conn.table(Beneficio.fqtn).where('idVaga', '=', id).delete();

    await conn.table(Vaga.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAll(List<Vaga> itens, {Connection? connection}) async {
    for (final item in itens) {
      await removeById(item.id, connection: connection);
    }
  }

  Future<void> removeAllInTransaction(List<Vaga> itens) async {
    await db.transaction((ctx) async {
      await removeAll(itens, connection: ctx);
    });
  }
}
