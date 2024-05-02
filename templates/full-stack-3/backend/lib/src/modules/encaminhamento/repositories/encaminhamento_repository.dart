import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class EncaminhamentoRepository {
  final Connection db;
  EncaminhamentoRepository(this.db);

  /// lista todos encaminhamentos
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Encaminhamento.fqtn);

    query.selectRaw('''
	    encaminhamentos.*
	    ,pessoas.nome AS "nomeCandidato"
      ,banco_empregos.candidatos."idPessoaFisica" AS "idPessoa"
	    ,banco_empregos.vagas."idEmpregador"
	    ,banco_empregos.vagas."idCargo" 
	    ,banco_empregos.cargos.nome AS "nomeCargo"
      ,p_empregador.nome as "nomeEmpregador"
      ,p_resp.nome as "usuarioResponsavelNome"
    ''');
    query.join(Candidato.fqtn, 'candidatos.idCandidato', '=',
        'encaminhamentos.idCandidato');
    query.join(Pessoa.fqtn, 'pessoas.id', '=', 'candidatos.idPessoaFisica');
    query.join(Vaga.fqtn, 'vagas.id', '=', 'encaminhamentos.idVaga');
    query.join(Pessoa.fqtn + ' as p_empregador', 'p_empregador.id', '=',
        'vagas.idEmpregador');

    query.join(Cargo.fqtn, 'cargos.id', '=', 'vagas.idCargo');

    query.leftJoin(Pessoa.fqtn + ' as p_resp', 'p_resp.id', '=',
        'encaminhamentos.idUsuario');

    // para filtrar encaminhados para um empregador
    if (filtros?.idEmpregador != null && filtros?.idEmpregador != -1) {
      query.where(Vaga.idEmpregadorFqCol, '=', filtros!.idEmpregador!);
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
        query.orderBy('encaminhamentos.data');
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

  /// lista todos encaminhamentos para o portal SIBEM (para uma empresa especifica)
  Future<DataFrame<Map<String, dynamic>>> getAllByEmpregador(int idEmpregador,
      {Filters? filtros}) async {
    final query = db.table(Encaminhamento.fqtn);

    query.selectRaw('''
	    encaminhamentos.*
	    ,pessoas.nome AS "nomeCandidato"
      ,candidatos."idPessoaFisica" AS "idPessoa"
	    ,vagas."idEmpregador"
	    ,vagas."idCargo" 
      ,vagas."dataAbertura" AS "dataAberturaVaga" 
	    ,cargos.nome AS "nomeCargo"
      ,p_empregador.nome as "nomeEmpregador"
      ,p_resp.nome as "usuarioResponsavelNome"
    ''');
    query.join(Candidato.fqtn, 'candidatos.idCandidato', '=',
        'encaminhamentos.idCandidato');
    query.join(Pessoa.fqtn, 'pessoas.id', '=', 'candidatos.idPessoaFisica');
    query.join(Vaga.fqtn, 'vagas.id', '=', 'encaminhamentos.idVaga');
    query.join(Pessoa.fqtn + ' as p_empregador', 'p_empregador.id', '=',
        'vagas.idEmpregador');

    query.join(Cargo.fqtn, 'cargos.id', '=', 'vagas.idCargo');

    query.leftJoin(Pessoa.fqtn + ' as p_resp', 'p_resp.id', '=',
        'encaminhamentos.idUsuario');

    // para filtrar encaminhados para um empregador
    query.where(Vaga.idEmpregadorFqCol, '=', idEmpregador);

    if (filtros?.statusEncaminhamento != null) {
      query.where(
          Encaminhamento.statusColFq, '=', filtros?.statusEncaminhamento);
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
        query.orderBy('encaminhamentos.data');
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

  Future<Encaminhamento?> getById(int idEncaminhamento) async {
    final data = await getByIdAsMap(idEncaminhamento);
    return data != null ? Encaminhamento.fromMap(data) : null;
  }

  Future<Map<String, dynamic>?> getByIdAsMap(int idEncaminhamento) async {
    final data = await db
        .table(Encaminhamento.fqtn)
        .selectRaw('encaminhamentos.* ')
        .where('encaminhamentos.id', '=', idEncaminhamento)
        .first();

    if (data == null) {
      //throw Exception('Não encontrado com o id = $idEncaminhamento');
      return null;
    }

    final idCandidato = data['idCandidato'];

    // Obter dados da tabela vaga empregadorNome
    final vagaData = await db
        .table(Vaga.fqtn)
        .selectRaw(
            'vagas.*,	cargos.nome AS "cargoNome", pessoas.nome AS "empregadorNome"')
        .join(Encaminhamento.fqtn, 'encaminhamentos.idVaga', '=', 'vagas.id')
        .join(Cargo.fqtn, 'cargos.id', '=', 'vagas.idCargo')
        .join(Pessoa.fqtn, 'pessoas.id', '=', 'vagas.idEmpregador')
        .where('encaminhamentos.id', '=', idEncaminhamento)
        .first();

    if (vagaData == null) {
      throw Exception('Falha ao obter a Vaga deste Encaminhamento');
    }

    data['vaga'] = vagaData;

    // Obter dados da tabela empregador
    final empregadorData = await db
        .table(Empregador.fqtn)
        .selectRaw('empregadores.*,	pessoas.*')
        .join(Vaga.fqtn, 'vagas.idEmpregador', '=', 'empregadores.idPessoa')
        .join(Pessoa.fqtn, 'pessoas.id', '=', 'empregadores.idPessoa')
        .join(Encaminhamento.fqtn, 'encaminhamentos.idVaga', '=', 'vagas.id')
        .where('encaminhamentos.id', '=', idEncaminhamento)
        .first();

    data['empregador'] = empregadorData;

    // Obter dados da tabela candidato
    final candidatoData = await db
        .table(Candidato.fqtn)
        .selectRaw('''
          candidatos.*,
          pessoas_fisicas.*,
          pessoas.*,
          ${ExperienciaCandidatoCargo.experienciaFqCol}
        ''')
        .join(PessoaFisica.fqtn, PessoaFisica.idPessoaFqCol, '=',
            Candidato.idPessoaFqCol)
        .join(Pessoa.fqtn, Pessoa.idFqCol, '=', PessoaFisica.idPessoaFqCol)
        .join(ExperienciaCandidatoCargo.fqtn, (JoinClause jc) {
          jc.on(ExperienciaCandidatoCargo.idCandidatoFqCol, '=',
              Candidato.idCandidatoFqCol);
          jc.on(ExperienciaCandidatoCargo.idCargoFqCol, '=',
              db.raw(vagaData['idCargo'].toString()));
        })
        .where(Candidato.idCandidatoFqCol, '=', idCandidato)
        .first();

    data['candidato'] = candidatoData;

    final userResp = await db
        .table(Pessoa.fqtn)
        .selectRaw('nome')
        .where('pessoas.id', '=', data['idUsuario'])
        .first();

    if (userResp != null) {
      data['usuarioResponsavelNome'] = userResp['nome'];
    }

    return data;
  }

  Future<void> createInTransaction(
      int idUsuarioLogado, Encaminhamento encaminhamento) async {
    await db.transaction((ctx) async {
      await create(idUsuarioLogado, encaminhamento, connection: ctx);
    });
  }

  Future<void> create(int idUsuarioLogado, Encaminhamento encaminhamento,
      {Connection? connection}) async {
    final conn = connection ?? db;
    encaminhamento.idUsuario = idUsuarioLogado;
    encaminhamento.data = DateTime.now();

    await conn.table(Encaminhamento.fqtn).insert(encaminhamento.toInsert());

    final qtdEncaminhada = (encaminhamento.quantidadeEncaminhada ?? 0) + 1;

    final vaga = await conn
        .table(Vaga.fqtn)
        .where(Vaga.idCol, '=', encaminhamento.idVaga)
        .first();

    final numeroEncaminhamentos = vaga!['numeroEncaminhamentos'];

    print(
        'create qtdEncaminhada $qtdEncaminhada | numeroEncaminhamentos: ${numeroEncaminhamentos}');

    if (qtdEncaminhada == numeroEncaminhamentos) {
      await conn
          .table(Vaga.fqtn)
          .where(Vaga.idCol, '=', encaminhamento.idVaga)
          .update({
        Vaga.quantidadeEncaminhadaCol: qtdEncaminhada,
        Vaga.bloqueioEncaminhamentoCol: true,
      });

      final bloq = BloqueioEncaminhamento(
          idVaga: encaminhamento.idVaga,
          data: DateTime.now(),
          justificativa:
              'Bloqueio automático ao se atingir o número máximo de encaminhamento.',
          idUsuarioResponsavel: idUsuarioLogado,
          acao: TipoBloqueioEncaminhamento.bloqueioAutomatico);

      await conn.table(BloqueioEncaminhamento.fqtn).insert(bloq.toInsertMap());
    } else {
      print('encaminhamentoRepository@qtdEncaminhada: ${qtdEncaminhada}');
      await conn
          .table(Vaga.fqtn)
          .where('id', '=', encaminhamento.idVaga)
          .update({
        'quantidadeEncaminhada': qtdEncaminhada,
      });
    }
  }

  Future<void> update(Encaminhamento encaminhamento,
      {Connection? connection}) async {
    final conn = connection ?? db;

    await conn
        .table(Encaminhamento.fqtn)
        .where('id', '=', encaminhamento.id)
        .update(encaminhamento.toUpdate());
  }

  Future<void> updateStatus(idUsuarioLogado, Encaminhamento encaminhamento,
      {Connection? connection}) async {
    final conn = connection ?? db;

    encaminhamento.idUsuarioAlteracao = idUsuarioLogado;
    encaminhamento.dataAlteracao = DateTime.now();

    await conn
        .table(Encaminhamento.fqtn)
        .where(Encaminhamento.idColFq, '=', encaminhamento.id)
        .update(encaminhamento.toUpdate());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;

    final encData = await conn
        .table(Encaminhamento.fqtn)
        .selectRaw(
            'encaminhamentos.*, vagas."quantidadeEncaminhada", vagas."numeroEncaminhamentos"')
        .join(Vaga.fqtn, 'encaminhamentos.idVaga', '=', 'vagas.id')
        .where('encaminhamentos.id', '=', id)
        .first();

    if (encData == null) {
      throw Exception('Encaminhamento com id = $id não existe');
    }

    final encaminhamento = Encaminhamento.fromMap(encData);

    final qtdEncaminhada = (encaminhamento.quantidadeEncaminhada ?? 0);
    print('removeById qtdEncaminhada: $qtdEncaminhada ');
    print(
        'removeById new qtdEncaminhada: ${qtdEncaminhada > 0 ? qtdEncaminhada - 1 : qtdEncaminhada} ');
    if (qtdEncaminhada == encaminhamento.numeroEncaminhamentos) {
      await conn
          .table(Vaga.fqtn)
          .where('id', '=', encaminhamento.idVaga)
          .update({
        'quantidadeEncaminhada':
            qtdEncaminhada > 0 ? qtdEncaminhada - 1 : qtdEncaminhada,
        'bloqueioEncaminhamento': false,
      });

      await conn
          .table(BloqueioEncaminhamento.fqtn)
          .where('idVaga', '=', encaminhamento.idVaga)
          .delete();
    } else {
      //quantidadeEncaminhada
      //numeroEncaminhamentos
      await conn
          .table(Vaga.fqtn)
          .where('id', '=', encaminhamento.idVaga)
          .update({
        'quantidadeEncaminhada':
            qtdEncaminhada > 0 ? qtdEncaminhada - 1 : qtdEncaminhada,
      });
    }

    await conn.table(Encaminhamento.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeByIdInTransaction(int id) async {
    await db.transaction((ctx) async {
      await removeById(id, connection: ctx);
    });
  }

  Future<void> removeAll(List<Encaminhamento> itens,
      {Connection? connection}) async {
    for (var item in itens) {
      await removeById(item.id, connection: connection);
    }
  }

  Future<void> removeAllInTransaction(List<Encaminhamento> itens) async {
    await db.transaction((ctx) async {
      await removeAll(itens, connection: ctx);
    });
  }
}
