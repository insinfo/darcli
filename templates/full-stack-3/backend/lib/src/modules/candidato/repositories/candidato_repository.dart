import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class CandidatoRepository {
  final Connection db;
  CandidatoRepository(this.db);

  /// Faz a listagem de pessoa fisica/Candidato
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final conn = db;
    final query = conn.table(Candidato.fqtn);

    query.selectRaw('''candidatos.*,
	                   pessoas_fisicas.*,	                  
	                   pessoas.*,
                     escolaridades."ordemGraduacao",
CASE
	WHEN candidatos."dataAlteracaoCandidato" is not null AND (now() - candidatos."dataAlteracaoCandidato" ) > INTERVAL '1 year'  THEN
		'vencido' 		
	WHEN candidatos."dataAlteracaoCandidato" is null AND (now() - candidatos."dataCadastroCandidato" ) > INTERVAL '1 year' THEN 	
	'vencido' 	
ELSE 
	'válido' 
END  as status
${filtros?.idEmpregador != null ? ', ${Encaminhamento.statusColFq} as "statusEncaminhamento"' : ''}
                     ''');

    query.join(PessoaFisica.fqtn, 'pessoas_fisicas.idPessoa', '=',
        'candidatos.idPessoaFisica');
    query.join(Pessoa.fqtn, 'pessoas.id', '=', 'candidatos.idPessoaFisica');
    //  Complemento Pessoa Fisica
    query.join(
        ComplementoPessoaFisica.fqtn,
        'complementos_pessoas_fisicas.idPessoa',
        '=',
        'candidatos.idPessoaFisica',
        'left');
    // Escolaridade
    query.join(Escolaridade.fqtn, 'escolaridades.id', '=',
        'complementos_pessoas_fisicas.idEscolaridade', 'left');

    // para filtrar candidatos encaminhados para um empregador
    if (filtros?.idEmpregador != null && filtros?.idEmpregador != -1) {
      //Encaminhamento
      query.join(Encaminhamento.fqtn, (JoinClause jc) {
        jc.on(Encaminhamento.idCandidatoColFq, '=', Candidato.idCandidatoFqCol);
      }, null, null, 'right');
      //Vaga
      query.join(Vaga.fqtn, (JoinClause jc) {
        jc.on(Vaga.idFqCol, '=', Encaminhamento.idVagaColFq);
        //filtra por empregador
        jc.on(Vaga.idEmpregadorFqCol, '=',
            QueryExpression("'${filtros!.idEmpregador}'"));
      });
      //
      //query.where(Vaga.idEmpregadorFqCol, '=', filtros!.idEmpregador!);
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

    // filtrar candidatos que correspondam à vaga
    if (filtros?.idVaga != null && filtros?.idVaga != -1) {
      final vagaRepo = VagaRepository(conn);
      final vaga = await vagaRepo.getById(filtros!.idVaga!);
      // print('CandidatoRepository@getAll idVaga: ${filtros.idVaga} vaga.id: ${vaga.id}');
      // print('CandidatoRepository@getAll idVaga: vaga.ordemGraduacao: ${vaga.ordemGraduacao}');
      print('filtros.matchEscolaridade ${filtros.matchEscolaridade}');
      //filtra por escolaridade ordemGraduacao
      if (filtros.matchEscolaridade == true) {
        query.where(
            Escolaridade.ordemGraduacaoFqCol, '>=', vaga.ordemGraduacao);
      }
      print('filtros.matchCargo ${filtros.matchCargo}');
      print('filtros.matchExperiencia ${filtros.matchExperiencia}');
      //filtra por cargo
      if (filtros.matchCargo == true) {
        query.join(ExperienciaCandidatoCargo.fqtn, (JoinClause jc) {
          jc.on(ExperienciaCandidatoCargo.idCandidatoFqCol, '=',
              Candidato.idCandidatoFqCol);
          jc.on(ExperienciaCandidatoCargo.idCargoFqCol, '=',
              db.raw('${vaga.idCargo}'));
        });

        //filtra por tempo de experiencia
        if (filtros.matchExperiencia == true && vaga.exigeExperiencia == true) {
          final tempoMinimoExp = vaga.tempoMinimoExperiencia;
          final tempoMaximoExp = vaga.tempoMaximoExperiencia;
          print(
              'experienciaMinimoExigida $tempoMinimoExp tempoMaximoExperiencia ${vaga.tempoMaximoExperiencia} ');
          query.where(ExperienciaCandidatoCargo.experienciaFqCol, '=', true);
          if (vaga.tempoMaximoExperiencia == null) {
            query.whereRaw(
                ''' ( experiencias_candidatos_cargos."tempoExperienciaFormal" 
              ${vaga.aceitaExperienciaMei == true ? ' + COALESCE(experiencias_candidatos_cargos."tempoExperienciaMei",0) ' : ''}
              ${vaga.experienciaInformal == true ? ' + COALESCE(experiencias_candidatos_cargos."tempoExperienciaInformal",0) ' : ''}  )               
              >= $tempoMinimoExp ''');
          } else {
            query.whereRaw(
                '''( ( experiencias_candidatos_cargos."tempoExperienciaFormal" 
              ${vaga.aceitaExperienciaMei == true ? ' + COALESCE(experiencias_candidatos_cargos."tempoExperienciaMei",0) ' : ''}
              ${vaga.experienciaInformal == true ? ' + COALESCE(experiencias_candidatos_cargos."tempoExperienciaInformal",0) ' : ''}  )               
             BETWEEN  $tempoMinimoExp AND $tempoMaximoExp )''');
          }
        }
      }

      print('filtros.matchFumante ${filtros.matchFumante}');
      // filtra por aceita fumante
      if (filtros.matchFumante == true && vaga.aceitaFumante != null) {
        query.where(Candidato.fumanteFqCol, '=', vaga.aceitaFumante);
      }
      print('filtros.matchIdade ${filtros.matchIdade}');
      // filtra por idade
      if (filtros.matchIdade == true) {
        query.whereRaw(
            ''' (date_part('year', now()) - date_part('year', "dataNascimento")) >= ${vaga.idadeMinima} ''');
        if (vaga.idadeMaxima != null) {
          query.whereRaw(
              ''' (date_part('year', now()) - date_part('year', "dataNascimento")) <= ${vaga.idadeMaxima} ''');
        }
      }
      print('filtros.matchCurso ${filtros.matchCurso}');
      // filtra por curso
      if (filtros.matchCurso == true) {
        if (vaga.cursos.isNotEmpty) {
          final cursosExigidos = vaga.cursos
              .where((cu) => cu.obrigatorio == true)
              .map((e) => e.id)
              .toList();

          if (cursosExigidos.isNotEmpty) {
            print('cursosExigidos ${cursosExigidos}');
            query.leftJoin(CandidatoCurso.fqtn, (JoinClause jc) {
              jc.on('candidatos_cursos.idCandidato', '=',
                  'candidatos.idCandidato');
            });
            query.whereIn('candidatos_cursos.idCurso', cursosExigidos);
          }
        }
      }
      print(
          'filtros.matchConhecimentosExtras ${filtros.matchConhecimentosExtras}');
      // filtra por  Conhecimentos Extras
      if (filtros.matchConhecimentosExtras == true) {
        if (vaga.conhecimentosExtras.isNotEmpty) {
          final conhecimentosExigidos = vaga.conhecimentosExtras
              .where((cu) => cu.obrigatorio == true)
              .map((e) => e.id)
              .toList();

          if (conhecimentosExigidos.isNotEmpty) {
            print('conhecimentosExigidos ${conhecimentosExigidos}');
            query.leftJoin(CandidatoConhecimentoExtra.fqtn, (JoinClause jc) {
              jc.on(CandidatoConhecimentoExtra.idCandidatoFqCol, '=',
                  Candidato.idCandidatoFqCol);
            });
            query.whereIn('candidatos_conhecimentos_extras.idConhecimentoExtra',
                conhecimentosExigidos);
          }
        }
      }
      // para não duplicar as linhas de candidatos
      if (filtros.matchCurso == true ||
          filtros.matchConhecimentosExtras == true) {
        query.groupBy([
          'candidatos.idCandidato',
          'pessoas_fisicas.idPessoa',
          'pessoas.id',
          'escolaridades.ordemGraduacao'
        ]);
      }

      // filtra por PCD
      print('filtros.matchPcd ${filtros.matchPcd}');
      if (filtros.matchPcd == true && vaga.vagaPcd == true) {
        query.whereRaw(''' complementos_pessoas_fisicas.deficiente = true ''');
      }

      // filtra por Sexo
      print('filtros.matchSexo ${filtros.matchSexo}');
      if (filtros.matchSexo == true &&
          vaga.sexoBiologico != null &&
          vaga.sexoBiologico?.toLowerCase() != 'ambos') {
        query.whereRaw(''' Lower(pessoas_fisicas.sexo) = ? ''',
            [vaga.sexoBiologico!.toLowerCase()]);
      }
      // filtra por identidade de Genero
      print('filtros.matchGenero ${filtros.matchGenero}');
      if (filtros.matchGenero == true && vaga.identidadeGenero != null) {
        query.whereRaw(''' Lower(candidatos.identidadeGenero) = ? ''',
            [vaga.identidadeGenero!.toLowerCase()]);
      }
      // filtra por validade do cadastro
      print('filtros.matchValidadeCadastro ${filtros.matchValidadeCadastro}');
      if (filtros.matchValidadeCadastro == true) {
        query.whereRaw(''' 
        	(candidatos."dataAlteracaoCandidato" is not null AND (now() - candidatos."dataAlteracaoCandidato" ) <= INTERVAL '1 year'  OR		
          candidatos."dataAlteracaoCandidato" is null AND (now() - candidatos."dataCadastroCandidato" ) <= INTERVAL '1 year' )	
        ''');
      }
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      if (totalRecords > 1) {
        query.orderBy('idCandidato', 'desc');
      }
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    final dados = await query.get();

    if (dados.isNotEmpty) {
      final idsPessoa = dados.map((e) => e['idPessoaFisica']).toList();
      final idsCandidato = dados.map((e) => e['idCandidato']).toList();

      // final telefones = await conn
      //     .table(Telefone.fqtn)
      //     .whereIn(Telefone.idPessoaCol, idsPessoa)
      //     .get();
      // if (telefones.isNotEmpty) {
      //   for (var item in dados) {
      //     item['telefones'] = telefones
      //         .where((tel) => tel['idPessoa'] == item['idPessoaFisica'])
      //         .toList();
      //   }
      // }

      final cargos = await conn
          .table(Cargo.fqtn)
          .select([
            '${Cargo.tableName}.*',
            ExperienciaCandidatoCargo.experienciaFqCol,
            ExperienciaCandidatoCargo.idCandidatoFqCol,
            ExperienciaCandidatoCargo.tempoExperienciaFormalFqCol,
            ExperienciaCandidatoCargo.tempoExperienciaInformalFqCol,
            ExperienciaCandidatoCargo.tempoExperienciaMeiFqCol,
          ])
          .leftJoin(ExperienciaCandidatoCargo.fqtn, (JoinClause jc) {
            jc.on(ExperienciaCandidatoCargo.idCargoFqCol, '=', Cargo.idFqCol);
          })
          .whereIn(ExperienciaCandidatoCargo.idCandidatoFqCol, idsCandidato)
          .get();

      if (cargos.isNotEmpty) {
        for (var item in dados) {
          item['cargosDesejados'] = cargos
              .where((tel) => tel['idCandidato'] == item['idCandidato'])
              .toList();
        }
      }

      final complementosPe = await db
          .table(ComplementoPessoaFisica.fqtn)
          .selectRaw(
              'complementos_pessoas_fisicas.*, escolaridades.nome AS "nomeEscolaridade"')
          .join(
              Escolaridade.fqtn,
              'complementos_pessoas_fisicas.idEscolaridade',
              '=',
              'escolaridades.id')
          .whereIn('idPessoa', idsPessoa)
          .get();

      if (complementosPe.isNotEmpty) {
        for (var item in dados) {
          final comp = complementosPe
              .where((comp) => comp['idPessoa'] == item['idPessoaFisica']);
          if (comp.isNotEmpty) {
            item['complementoPessoaFisica'] = comp.first;
          }
        }
      }
    }

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  /// [campo] coluna do bamco de dados
  /// [value] idCandidato | idPessoaFisica | usuarioRespAlteracao | etc...
  Future<Map<String, dynamic>?> getByCampoAsMap(String campo, dynamic value,
      {Connection? connection}) async {
    final conn = connection ?? db;

    final query = conn
        .table(Candidato.fqtn)
        .selectRaw(
            '''candidatos.*, pessoas_fisicas.*, pessoas.*, escolaridades."ordemGraduacao"  ''')
        .join(PessoaFisica.fqtn, 'pessoas_fisicas.idPessoa', '=',
            'candidatos.idPessoaFisica', 'left')
        .join(Pessoa.fqtn, 'pessoas.id', '=', 'candidatos.idPessoaFisica',
            'left');

    //  Complemento Pessoa Fisica
    query.join(
        ComplementoPessoaFisica.fqtn,
        'complementos_pessoas_fisicas.idPessoa',
        '=',
        'candidatos.idPessoaFisica',
        'left');
    // Escolaridade
    query.join(Escolaridade.fqtn, 'escolaridades.id', '=',
        'complementos_pessoas_fisicas.idEscolaridade', 'left');

    query.where(campo, '=', value);

    var data = await query.first();

    if (data == null) {
      // throw Exception(
      //     'CandidatoRepository@getByCampoAsMap Candidato com $campo = $value não localizado!');
      return null;
    }

    var idPessoaResponsavel = data['usuarioRespAlteracao'];

    final idPessoa = data['idPessoaFisica'];
    final idCandidato = data['idCandidato'];

    final telefones =
        await conn.table(Telefone.fqtn).where('idPessoa', '=', idPessoa).get();

    if (telefones.isNotEmpty) {
      data['telefones'] = telefones;
    }

    final enderecos = await conn
        .table(PessoaEndereco.fqtn)
        .selectRaw(
            'enderecos.*, pessoas_enderecos.*, bairros.nome AS "nomeBairro"')
        .join(
            Endereco.fqtn, 'pessoas_enderecos.idEndereco', '=', 'enderecos.id')
        .join(Bairro.fqtn, 'bairros.id', '=', 'enderecos.idBairro')
        .where('idPessoa', '=', idPessoa)
        .get();

    if (enderecos.isNotEmpty) {
      data['enderecos'] = enderecos;
    }

    final origem = await db
        .table(PessoaOrigem.fqtn)
        .selectRaw('pessoas_origens.*')
        .where('acao', '=', PessoaOrigem.ACAO_INSERIR)
        .where('idPessoa', '=', idPessoa)
        .first();

    if (origem != null) {
      data['pessoaOrigem'] = origem;
    }

    final complementoPessoaFisica = await db
        .table(ComplementoPessoaFisica.fqtn)
        .selectRaw('complementos_pessoas_fisicas.*')
        .where('idPessoa', '=', idPessoa)
        .first();

    if (complementoPessoaFisica != null) {
      data['complementoPessoaFisica'] = complementoPessoaFisica;
    }

    final cursos = await db
        .table(Curso.fqtn)
        .selectRaw(
            ''' cursos.*, candidatos_cursos."idCandidato", candidatos_cursos."dataConclusao" ''')
        .join(
            CandidatoCurso.fqtn, 'cursos.id', '=', 'candidatos_cursos.idCurso')
        .where('candidatos_cursos.idCandidato', '=', idCandidato)
        .get();

    data['cursos'] = cursos;

    final conhecimentosExtras = await db
        .table(ConhecimentoExtra.fqtn)
        .selectRaw('''
                  ${ConhecimentoExtra.tableName}.*,
	                tipos_conhecimentos.nome AS "tipoConhecimentoNome",
	                candidatos_conhecimentos_extras."nivelConhecimento" 
                  ''')
        .join(TipoConhecimento.fqtn, 'tipos_conhecimentos.id', '=',
            'conhecimentos_extras.idTipoConhecimento')
        .join(
            CandidatoConhecimentoExtra.fqtn,
            CandidatoConhecimentoExtra.idConhecimentoExtraFqCol,
            '=',
            'conhecimentos_extras.id')
        .where('candidatos_conhecimentos_extras.idCandidato', '=', idCandidato)
        .get();

    data['conhecimentosExtras'] = conhecimentosExtras;

    var dadosCargos = await db
        .table(Cargo.fqtn)
        .select([
          '${Cargo.tableName}.*',
          ExperienciaCandidatoCargo.experienciaFqCol,
          ExperienciaCandidatoCargo.idCandidatoFqCol,
          ExperienciaCandidatoCargo.tempoExperienciaFormalFqCol,
          ExperienciaCandidatoCargo.tempoExperienciaInformalFqCol,
          ExperienciaCandidatoCargo.tempoExperienciaMeiFqCol,
        ])
        .leftJoin(ExperienciaCandidatoCargo.fqtn, (JoinClause jc) {
          jc.on(ExperienciaCandidatoCargo.idCargoFqCol, '=', Cargo.idFqCol);
        })
        .where(ExperienciaCandidatoCargo.idCandidatoFqCol, '=', idCandidato)
        .get();

    data['cargosDesejados'] = dadosCargos;

    if (idPessoaResponsavel != null) {
      var responsavel = await db
          .table(Pessoa.fqtn)
          .selectRaw(''' ${Pessoa.nomeFqCol} AS "nomeResponsavel" ''')
          .where(Pessoa.idFqCol, '=', idPessoaResponsavel)
          .first();
      if (responsavel != null) {
        data['nomeResponsavel'] = responsavel['nomeResponsavel'];
      }
    }

    return data;
  }

  Future<Candidato> getByCpf(String cpf) async {
    final cpfValue = cpf.replaceAll(RegExp('[^0-9]'), '');
    final data = await getByCampoAsMap('cpf', cpfValue);
    if (data == null) {
      throw Exception('Candidato com cpf=$cpf não localizado!');
    }
    return Candidato.fromMap(data);
  }

  Future<Map<String, dynamic>?> getByCpfAsMap(String cpf) async {
    final cpfValue = cpf.replaceAll(RegExp('[^0-9]'), '');
    final result = await getByCampoAsMap('cpf', cpfValue);
    return result;
  }

  /// get By idCandidato
  Future<Map<String, dynamic>?> getByIdCandidatoAsMap(int idCandidato) async {
    final result = await getByCampoAsMap(Candidato.idCandidatoCol, idCandidato);
    return result;
  }

  Future<void> create(int idUsuarioLogado, Candidato candidato,
      {Connection? connection}) async {
    final conn = connection ?? db;

    candidato.dataAlteracaoCandidato = null;
    candidato.dataCadastroCandidato = DateTime.now();

    // 1º verifica se ja existe pessoa ai atualiza ou cadastra
    candidato.cpf = candidato.cpf.replaceAll(RegExp('[^0-9]'), '');
    final pessoaRepo = PessoaFisicaRepository(conn);
    final isExistPessoa = await pessoaRepo.isExistByCpf(candidato.cpf);

    final pessoaFisica = candidato.getPessoaFisica();

    var idPessoa = -1;
    if (isExistPessoa) {
      idPessoa = await pessoaRepo.update(idUsuarioLogado, pessoaFisica);
    } else {
      idPessoa = await pessoaRepo.create(idUsuarioLogado, pessoaFisica);
    }
    candidato.idPessoaFisica = idPessoa;

    final idCandidato = await conn.table(Candidato.fqtn).insertGetId(
        candidato.toInsertCandidatoMap(), Candidato.idCandidatoCol);

    print('Candidato@create idCandidato $idCandidato');

    if (candidato.conhecimentosExtras.isNotEmpty == true) {
      for (var conExtra in candidato.conhecimentosExtras) {
        conExtra.idCandidato = idCandidato;
        await conn
            .table(CandidatoConhecimentoExtra.fqtn)
            .insert(conExtra.toInsertCandidatoConhecimentoExtra());
      }
    }

    if (candidato.cursos.isNotEmpty == true) {
      for (final curso in candidato.cursos) {
        curso.idCandidato = idCandidato;
        await conn
            .table(CandidatoCurso.fqtn)
            .insert(curso.toInsertCandidatoCurso());
      }
    }

    if (candidato.cargosDesejados.isNotEmpty == true) {
      for (final cargo in candidato.cargosDesejados) {
        cargo.idCandidato = idCandidato;
        await conn
            .table(ExperienciaCandidatoCargo.fqtn)
            .insert(cargo.toInsertExperienciaCandidatoCargo());
      }
    }
    //verifica se vem de candidato web
    print(
        'CandidatoRepository@create candidato.isFromWeb ${candidato.isFromWeb}');
    if (candidato.isFromWeb == true) {
      await CandidatoWebRepository(conn)
          .validar(candidato.cpf, idUsuarioLogado);
    }
  }

  Future<bool> isExisteByIdPessoa(int idPessoa,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final data = await conn
        .table(Candidato.fqtn)
        .where(Candidato.idPessoaCol, '=', idPessoa)
        .first();
    if (data == null) {
      return false;
    }
    return true;
  }

  Future<bool> isExisteByCpf(String cpf, {Connection? connection}) async {
    var conn = connection ?? db;
    var data = await conn
        .table(Candidato.fqtn)
        .selectRaw('${Candidato.tableName}.*')
        .join(
            PessoaFisica.fqtn,
            '${PessoaFisica.tableName}.${PessoaFisica.idPessoaCol}',
            '=',
            '${Candidato.tableName}.${Candidato.idPessoaCol}')
        .where('${PessoaFisica.tableName}.${PessoaFisica.cpfCol}', '=', cpf)
        .first();
    if (data == null) {
      return false;
    }
    return true;
  }

  /// retorna um Map de Candidato se existir se não retorna nulo
  Future<Map<String, dynamic>?> isExisteByCpfAsMap(String cpf,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final data = await conn
        .table(Candidato.fqtn)
        .selectRaw(''' ${Candidato.tableName}.*, ${PessoaFisica.tableName}.*,
CASE
	WHEN candidatos."dataAlteracaoCandidato" is not null AND (now() - candidatos."dataAlteracaoCandidato" ) > INTERVAL '1 year'  THEN
		'vencido' 		
	WHEN candidatos."dataAlteracaoCandidato" is null AND (now() - candidatos."dataCadastroCandidato" ) > INTERVAL '1 year' THEN 	
	'vencido' 	
ELSE 
	'válido' 
END as status
        ''')
        .join(
            PessoaFisica.fqtn,
            '${PessoaFisica.tableName}.${PessoaFisica.idPessoaCol}',
            '=',
            '${Candidato.tableName}.${Candidato.idPessoaCol}')
        .where('${PessoaFisica.tableName}.${PessoaFisica.cpfCol}', '=', cpf)
        .first();
    return data;
  }

  Future<void> createInTransaction(
      int idUsuarioLogado, Candidato candidato) async {
    await db.transaction((ctx) async {
      await create(idUsuarioLogado, candidato, connection: ctx);
    });
  }

  Future<void> updateInTransaction(
      int idUsuarioLogado, Candidato candidato) async {
    await db.transaction((ctx) async {
      await update(idUsuarioLogado, candidato, connection: ctx);
    });
  }

  Future<void> update(int idUsuarioLogado, Candidato candidato,
      {Connection? connection, bool updatePessoa = true}) async {
    final conn = connection ?? db;

    candidato.dataAlteracaoCandidato = DateTime.now();
    candidato.dataAlteracao = DateTime.now();
    candidato.usuarioRespAlteracao = idUsuarioLogado;

    if (updatePessoa == true) {
      final pessoaFisica = candidato.getPessoaFisica();

      // 1º verifica se ja existe pessoa ai atualiza ou cadastra
      candidato.cpf = candidato.cpf.replaceAll(RegExp('[^0-9]'), '');
      final pessoaRepo = PessoaFisicaRepository(conn);
      final isExistPessoa = await pessoaRepo.isExistByCpf(candidato.cpf);
      var idPessoa = -1;
      if (isExistPessoa) {
        idPessoa = await pessoaRepo.update(idUsuarioLogado, pessoaFisica);
      } else {
        idPessoa = await pessoaRepo.create(idUsuarioLogado, pessoaFisica);
      }
      candidato.idPessoaFisica = idPessoa;
    }
    final idCandidato = candidato.idCandidato;
    await conn
        .table(Candidato.fqtn)
        .where('idCandidato', '=', idCandidato)
        .update(candidato.toUpdateCandidatoMap());

    await conn
        .table(CandidatoConhecimentoExtra.fqtn)
        .where('idCandidato', '=', idCandidato)
        .delete();

    await conn
        .table(CandidatoCurso.fqtn)
        .where('idCandidato', '=', idCandidato)
        .delete();

    await conn
        .table(ExperienciaCandidatoCargo.fqtn)
        .where('idCandidato', '=', idCandidato)
        .delete();

    if (candidato.conhecimentosExtras.isNotEmpty == true) {
      for (var conExtra in candidato.conhecimentosExtras) {
        conExtra.idCandidato = idCandidato;
        await conn
            .table(CandidatoConhecimentoExtra.fqtn)
            .insert(conExtra.toInsertCandidatoConhecimentoExtra());
      }
    }

    if (candidato.cursos.isNotEmpty == true) {
      for (final curso in candidato.cursos) {
        curso.idCandidato = idCandidato;
        await conn
            .table(CandidatoCurso.fqtn)
            .insert(curso.toInsertCandidatoCurso());
      }
    }

    if (candidato.cargosDesejados.isNotEmpty == true) {
      for (final cargo in candidato.cargosDesejados) {
        cargo.idCandidato = idCandidato;
        await conn
            .table(ExperienciaCandidatoCargo.fqtn)
            .insert(cargo.toInsertExperienciaCandidatoCargo());
      }
    }
  }

  /// Exclui um registro de Candidato do banco de dados
  /// [id] - Id do registro a ser excluído.
  /// [connection] - Conexão com os dados do banco de dados.
  Future<void> removeById(int idCandidato, {Connection? connection}) async {
    final conn = connection ?? db;
    final candidatoMap = await conn
        .table(Candidato.fqtn)
        .where('idCandidato', '=', idCandidato)
        .first();
    if (candidatoMap == null) {
      throw Exception('Candidato com o idCandidato = $idCandidato não existe');
    }
    await conn
        .table(CandidatoConhecimentoExtra.fqtn)
        .where('idCandidato', '=', idCandidato)
        .delete();
    await conn
        .table(CandidatoCurso.fqtn)
        .where('idCandidato', '=', idCandidato)
        .delete();
    await conn
        .table(ExperienciaCandidatoCargo.fqtn)
        .where('idCandidato', '=', idCandidato)
        .delete();
    await conn
        .table(Candidato.fqtn)
        .where('idCandidato', '=', idCandidato)
        .delete();

    await PessoaFisicaRepository(conn)
        .removeById(candidatoMap['idPessoaFisica']);
  }

  /// Varre uma lista dos registros elecionados e para cada item lido pede a exclusão para o método excluir__
  /// - [itens] - Lista de dados de um ou mais registros.
  Future<void> removeAllInTransaction(List<Candidato> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.idCandidato, connection: ctx);
      }
    });
  }
}
