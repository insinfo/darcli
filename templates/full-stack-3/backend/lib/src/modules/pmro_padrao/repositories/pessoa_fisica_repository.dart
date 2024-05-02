import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class PessoaFisicaRepository {
  final Connection db;
  PessoaFisicaRepository(this.db);

  /// Faz a listagem de pessoa fisica
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Pessoa.fqtn);
    query.join('pessoas_fisicas', 'pessoas_fisicas.idPessoa', '=', 'pessoas.id',
        'inner');

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

  Future<PessoaFisica?> getByCpf(String cpf, {Connection? connection}) async {
    final conn = connection ?? db;
    final cpfValue = cpf.replaceAll(RegExp('[^0-9]'), '');
    return await getByCampo('cpf', cpfValue, connection: conn);
  }

  Future<Map<String, dynamic>?> getByIdAsMap(int id,
      {Connection? connection}) async {
    final conn = connection ?? db;
    //return await getByCampo('idPessoa', id, connection: conn);
    return await getByCampoAsMap('idPessoa', id, connection: conn);
  }

  Future<PessoaFisica?> getById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    return await getByCampo('idPessoa', id, connection: conn);
  }

  Future<PessoaFisica?> getByCampo(String campo, dynamic valor,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final data = await getByCampoAsMap(campo, valor, connection: conn);
    return data != null ? PessoaFisica.fromMap(data) : null;
  }

  Future<Map<String, dynamic>?> getByCampoAsMap(String campo, dynamic valor,
      {Connection? connection}) async {
    final conn = connection ?? db;

    final query = db.table(Pessoa.fqtn);
    query.join(PessoaFisica.fqtn, 'pessoas_fisicas.idPessoa', '=', 'pessoas.id',
        'inner');

    query.where(campo, '=', valor);

    final data = await query.first();
    if (data == null) {
      //throw Exception('Pessoa fisica não localizada!');
      return null;
    }
    final idPessoa = data['idPessoa'];

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

    var complementoPessoaFisica = await db
        .table(ComplementoPessoaFisica.fqtn)
        .selectRaw('complementos_pessoas_fisicas.*')
        .where('idPessoa', '=', idPessoa)
        .first();

    if (complementoPessoaFisica != null) {
      data['complementoPessoaFisica'] = complementoPessoaFisica;
    }

    return data;
  }

  Future<bool> isExistByCpf(String cpf, {Connection? connection}) async {
    final conn = connection ?? db;

    final cpfValue = cpf.replaceAll(RegExp('[^0-9]'), '');
    print('PessoaFisicaRepository@isExistByCpf $cpfValue');
    final query = conn
        .table(PessoaFisica.fqtn)
        .join(Pessoa.fqtn, 'pessoas.id', '=', 'pessoas_fisicas.idPessoa')
        .where('cpf', '=', cpfValue);

    final data = await query.first();
    if (data == null) {
      return false;
    }
    return true;
  }

  ///
  /// Faz a inclusão de uma pessoa fisica no banco de dados
  ///
  Future<int> create(int idUsuarioLogado, PessoaFisica pessoa,
      {Connection? connection}) async {
    final conn = connection ?? db;

    pessoa.dataInclusao = DateTime.now();
    pessoa.dataAlteracao = null;
    pessoa.tipo = 'fisica';

    if (!CPFValidator.isValid(pessoa.cpf)) {
      throw Exception('CPF não é valido');
    }

    print('PessoaFisicaRepository@create  ${pessoa.cpf}');

    //checar se ja existe
    if (await isExistByCpf(pessoa.cpf)) {
      throw Exception('Esta pessoa já esta cadastrada');
    }

    // 1º salva pessoa
    final idPessoa =
        await conn.table(Pessoa.fqtn).insertGetId(pessoa.toInsertPessoa());

    //Pega o id da pessoa inserida, primeira linha e primeiro campo que é o id.
    pessoa.idPessoa = idPessoa;
    pessoa.id = idPessoa;

    // 2º Faz o insert de pessoas_fisicas
    await conn.table(PessoaFisica.fqtn).insert(pessoa.toInsert());

    // 3º Faz o registro da origem do cadastro de pessoa
    final pessoaOrigem = PessoaOrigem(
        idPessoa: idPessoa,
        dataAcao: DateTime.now(),
        sistemaOrigem: BANCO_EMPREGO,
        acao: PessoaOrigem.ACAO_INSERIR,
        idPessoaResp: idUsuarioLogado);

    await conn.table(PessoaOrigem.fqtn).insert(pessoaOrigem.toInsertMap());

    // 4º salva telefones
    if (pessoa.telefones.isEmpty == true) {
      throw Exception('Pessoa tem que ter ao menos um telefone');
    }
    for (final tel in pessoa.telefones) {
      tel.idPessoa = idPessoa;
      await conn.table(Telefone.fqtn).insert(tel.toInsertMap());
    }

    // 5º salva endereços
    // Verificar se a pessoa possui endereço
    if (pessoa.enderecos.isEmpty == true) {
      throw Exception('Pessoa tem que ter endereço');
    }
    //Faz o insert de enderecos
    for (final end in pessoa.enderecos) {
      final idMunicipio = end.idMunicipio!;
      final nomeBairro = end.nomeBairro!;
      //checa se o bairro existe se não existir faz um insert
      var bairro = await BairroRepository(conn)
          .getByNomeAndIdMunicipio(nomeBairro, idMunicipio);

      if (bairro == null) {
        bairro = Bairro(
            idMunicipio: idMunicipio,
            nome: nomeBairro,
            validacaoCorreio: false,
            oficial: false);
        await BairroRepository(conn).create(bairro);
      }
      //checa se o endereço existe se não existir faz um insert
      var endereco = await EnderecoRepository(conn)
          .getByLogradouroIdBairroCep(end.logradouro, bairro.id, end.cep ?? '');

      if (endereco == null) {
        endereco = Endereco(
            cep: end.cep,
            logradouro: end.logradouro,
            idMunicipio: end.idMunicipio,
            idPais: end.idPais,
            idBairro: bairro.id,
            idUf: end.idUf,
            validacao: false,
            divergente: false,
            tipoLogradouro: end.tipoLogradouro);
        await EnderecoRepository(conn).create(endereco);
      }

      // Faz o insert de pessoas_enderecos
      end.idPessoa = idPessoa;
      end.idEndereco = endereco.id;
      await conn
          .table(PessoaEndereco.fqtn)
          .insert(end.toInsertPessoaEndereco());
    }

    // Faz o insert de complemento de pessoa fisica
    if (pessoa.complementoPessoaFisica != null) {
      pessoa.complementoPessoaFisica!.idPessoa = idPessoa;
      await conn
          .table(ComplementoPessoaFisica.fqtn)
          .insert(pessoa.complementoPessoaFisica!.toInsertMap());
    }
    return pessoa.id;
  }

  Future<int> createInTransaction(
      int idUsuarioLogado, PessoaFisica pessoa) async {
    return await db.transaction((ctx) async {
      return await create(idUsuarioLogado, pessoa, connection: ctx);
    });
  }

  ///
  /// Faz a alteração de uma pessoa fisica no banco de dados
  /// connection - conexão com o banco de dados (opcional). Se não for passado, usa a conexão padrão
  ///
  Future<int> update(int idUsuarioLogado, PessoaFisica pessoa,
      {Connection? connection, bool checkIsExist = true}) async {
    final conn = connection ?? db;

    pessoa.dataAlteracao = DateTime.now();
    pessoa.tipo = 'fisica';

    if (!CPFValidator.isValid(pessoa.cpf)) {
      throw Exception('CPF não é valido');
    }
    print('PessoaFisicaRepository@update  ${pessoa.cpf}');
    //checar se existe
    final pessoaExist = await getByCpf(pessoa.cpf);
    if (pessoaExist == null) {
      throw Exception('Esta pessoa não esta cadastrada');
    }

    final idPessoa = pessoaExist.id;
    pessoa.id = idPessoa;
    pessoa.idPessoa = idPessoa;
    // 1º Faz o update de pessoas
    await conn
        .table(Pessoa.fqtn)
        .where('id', '=', idPessoa)
        .update(pessoa.toUpdatePessoa());

    // 2º Faz o update de pessoas_fisicas
    await conn
        .table(PessoaFisica.fqtn)
        .where('idPessoa', '=', idPessoa)
        .update(pessoa.toUpdate());

    // 2º Faz o registro da origem do cadastro de pessoa
    final pessoaOrigem = PessoaOrigem(
        idPessoa: idPessoa,
        dataAcao: DateTime.now(),
        sistemaOrigem: BANCO_EMPREGO,
        acao: PessoaOrigem.ACAO_UPDATE,
        idPessoaResp: idUsuarioLogado);

    await conn.table(PessoaOrigem.fqtn).insert(pessoaOrigem.toInsertMap());

    // Verifica se pessoa e enderecos são nulos e depois verifica se enderecos está vazio
    if (pessoa.enderecos.isEmpty == true) {
      throw Exception('Pessoa tem que ter endereço');
    }

    // 3º Faz o update de telefones
    if (pessoa.telefones.isNotEmpty == true) {
      await conn.table(Telefone.fqtn).where('idPessoa', '=', idPessoa).delete();

      for (var tel in pessoa.telefones) {
        tel.idPessoa = idPessoa;
        await conn.table(Telefone.fqtn).insert(tel.toInsertMap());
      }
    }

    //Faz o update de pessoas_enderecos
    //Obter id´s de endereco de pessoa e removelos
    await conn
        .table(PessoaEndereco.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();

    for (var end in pessoa.enderecos) {
      final idMunicipio = end.idMunicipio!;
      final nomeBairro = end.nomeBairro!;

      //checa se o bairro existe se não existir faz um insert
      var bairro = await BairroRepository(conn)
          .getByNomeAndIdMunicipio(nomeBairro, idMunicipio);

      if (bairro == null) {
        bairro = Bairro(
            idMunicipio: idMunicipio,
            nome: nomeBairro,
            validacaoCorreio: false,
            oficial: false);
        await BairroRepository(conn).create(bairro);
      }

      //checa se o endereço existe se não existir faz um insert
      var endereco = await EnderecoRepository(conn).getByLogradouroIdBairroCep(
          end.logradouro, bairro.id, end.cep ?? '',
          connection: conn);

      if (endereco == null) {
        endereco = Endereco(
            cep: end.cep,
            logradouro: end.logradouro,
            idMunicipio: end.idMunicipio,
            idPais: end.idPais,
            idBairro: bairro.id,
            idUf: end.idUf,
            validacao: false,
            divergente: false,
            tipoLogradouro: end.tipoLogradouro);
        await EnderecoRepository(conn).create(endereco, connection: conn);
      }

      // Faz o insert de pessoas_enderecos
      end.idPessoa = idPessoa;
      end.idEndereco = endereco.id;
      await conn
          .table(PessoaEndereco.fqtn)
          .insert(end.toInsertPessoaEndereco());
    }

    //Faz o update de complementos_pessoas_fisicas
    if (pessoa.complementoPessoaFisica != null) {
      pessoa.complementoPessoaFisica!.idPessoa = idPessoa;

      final existCompP = await conn
          .table(ComplementoPessoaFisica.fqtn)
          .where('idPessoa', '=', idPessoa)
          .first();

      if (existCompP != null) {       
        await conn
            .table(ComplementoPessoaFisica.fqtn)
            .where('idPessoa', '=', idPessoa)
            .update(pessoa.complementoPessoaFisica!.toInsertMap());
      } else {
        await conn
            .table(ComplementoPessoaFisica.fqtn)
            .insert(pessoa.complementoPessoaFisica!.toInsertMap());
      }
    }

    return pessoa.idPessoa;
  }

  Future<int> alterarInTransaction(
      int idUsuarioLogado, PessoaFisica pessoa) async {
    return await db.transaction((ctx) async {
      return await update(idUsuarioLogado, pessoa, connection: ctx);
    });
  }

  ///
  /// Faz a exclusão de uma pessoa fisica no banco de dados
  ///
  Future<dynamic> removeById(int idPessoa, {Connection? connection}) async {
    final conn = connection ?? db;

    final isExist =
        await conn.table(Pessoa.fqtn).where('id', '=', idPessoa).first();
    if (isExist == null) {
      throw Exception('Não existe pessoa com este ID ($idPessoa)');
    }
    // print('removeById isExist $isExist ');

    // Pesquisa pelo id da pessoa na tabela pessoas_origens
    var result = await conn
        .table(PessoaOrigem.fqtn)
        .where('idPessoa', '=', idPessoa)
        .where('sistemaOrigem', '=', BANCO_EMPREGO)
        .where('acao', '=', PessoaOrigem.ACAO_INSERIR)
        .first();

    print('removeById Pesquisa pelo id da pessoa na tabela pessoas_origens ');
    //Verifica se a pessoa foi cadastrada por este sistema, se sim permite excluir
    if (result == null) {
      throw Exception(
          'Pessoa não pode ser excluida pois não foi cadastrada por este sistema');
    }

    //Obtem o endereço da pessoa
    result = await conn
        .table(PessoaEndereco.fqtn)
        .join(Endereco.fqtn, 'enderecos.id', '=', 'idEndereco')
        .where('idPessoa', '=', idPessoa)
        .first();

    print('removeById Obtem o endereço da pessoa ');

    //var enredeco = Endereco.fromMap(result!);

    //Deleta vinculação de endereço com pessoas
    await conn
        .table(PessoaEndereco.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();

    print('removeById Deleta vinculação de endereço com pessoas ');

    //Deleta telefones da pessoa
    await conn.table(Telefone.fqtn).where('idPessoa', '=', idPessoa).delete();

    print('removeById Deleta telefones da pessoa');

    //Deleta log de pessoas origens
    await conn
        .table(PessoaOrigem.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();

    print('removeById Deleta log de pessoas origens');

    //Deleta complemento de pessoa
    await conn
        .table(ComplementoPessoaFisica.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();

    print('removeById Deleta complemento de pessoa');

    //Deleta pessoa fisica
    await conn
        .table(PessoaFisica.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();

    print('removeById Deleta pessoa fisica');

    //Deleta pessoa
    await conn.table(Pessoa.fqtn).where('id', '=', idPessoa).delete();

    print('removeById Deleta pessoa');
  }

  Future<dynamic> removeAllInTransaction(List<PessoaFisica> items) async {
    await db.transaction((ctx) async {
      for (final p in items) {
        await removeById(p.idPessoa, connection: ctx);
      }
    });
  }
}
