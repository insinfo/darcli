import 'package:sibem_backend/sibem_backend.dart';

import 'package:eloquent/eloquent.dart';

class PessoaJuridicaRepository {
  final Connection db;
  PessoaJuridicaRepository(this.db);

  /// Faz a listagem de pessoa juridica
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Pessoa.fqtn);
    query.join(PessoaJuridica.fqtn, 'pessoas_juridicas.idPessoa', '=',
        'pessoas.id', 'inner');

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

  Future<PessoaJuridica?> getByCnpj(String cnpj,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final cnpjValue = cnpj.replaceAll(RegExp('[^0-9]'), '');
    return await getByCampo('cnpj', cnpjValue, connection: conn);
  }

  Future<PessoaJuridica?> getById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    return await getByCampo('idPessoa', id, connection: conn);
  }

  Future<Map<String, dynamic>?> getByIdAsMap(int id,
      {Connection? connection}) async {
    final conn = connection ?? db;
    return await getByCampoAsMap('idPessoa', id, connection: conn);
  }

  Future<PessoaJuridica?> getByCampo(String campo, dynamic valor,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final data = await getByCampoAsMap(campo, valor, connection: conn);
    return data != null ? PessoaJuridica.fromMap(data) : null;
  }

  Future<Map<String, dynamic>?> getByCampoAsMap(String campo, dynamic valor,
      {Connection? connection}) async {
    final conn = connection ?? db;

    final query = db.table(Pessoa.fqtn);
    query.join(PessoaJuridica.fqtn, 'pessoas_juridicas.idPessoa', '=',
        'pessoas.id', 'inner');
    if (campo == 'cnpj') {
      query.whereRaw(
          ''' regexp_replace(pessoas_juridicas.cnpj, '\\D','','g') = ? ''',
          [valor]);
    } else {
      query.where(campo, '=', valor);
    }

    final data = await query.first();

    if (data == null) {
      //throw Exception('Pessoa não localizada!');
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
        .where('idPessoa', '=', idPessoa)
        .first();

    if (origem != null) {
      data['pessoaOrigem'] = origem;
    }

    return data;
  }

  Future<bool> isExistByCnpj(String cnpj, {Connection? connection}) async {
    final conn = connection ?? db;

    final cnpjValue = cnpj.replaceAll(RegExp('[^0-9]'), '');
    print('PessoaJuridicaRepository@isExistByCnpj $cnpjValue');

    final query = conn
        .table(PessoaJuridica.fqtn)
        .join(Pessoa.fqtn, 'pessoas.id', '=', 'pessoas_juridicas.idPessoa')
        .where('cnpj', '=', cnpjValue);

    final data = await query.first();
    if (data == null) {
      return false;
    }
    return true;
  }

  Future<int> create(int idUsuarioLogado, PessoaJuridica pessoa,
      {Connection? connection, bool checkIsExist = true}) async {
    final conn = connection ?? db;

    pessoa.dataInclusao = DateTime.now();
    pessoa.dataAlteracao = null;
    pessoa.tipo = 'juridica';

    if (!CNPJValidator.isValid(pessoa.cnpj)) {
      throw Exception('CNPJ não é valido');
    }

    print('PessoaJuridicaRepository@create ${pessoa.cnpj}');

    //checar se ja existe
    if (checkIsExist) {
      if (await isExistByCnpj(pessoa.cnpj)) {
        throw Exception('Esta empresa já esta cadastrada');
      }
    }
    // 1º salva pessoa
    final idPessoa =
        await conn.table(Pessoa.fqtn).insertGetId(pessoa.toInsertPessoa());

    pessoa.idPessoa = idPessoa;
    pessoa.id = idPessoa;

    // 2º Faz o insert de pessoas_juridicas
    await conn.table(PessoaJuridica.fqtn).insert(pessoa.toInsertMap());

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

    // Verificar se a pessoa possui endereço
    if (pessoa.enderecos.isEmpty == true) {
      throw Exception('Pessoa tem que ter endereço');
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

    return pessoa.id;
  }

  Future<int> createInTransaction(
      int idUsuarioLogado, PessoaJuridica pessoa) async {
    return await db.transaction((ctx) async {
      return await create(idUsuarioLogado, pessoa, connection: ctx);
    });
  }

  Future<int> update(int idUsuarioLogado, PessoaJuridica pessoa,
      {Connection? connection}) async {
    final conn = connection ?? db;

    pessoa.dataAlteracao = DateTime.now();
    pessoa.tipo = 'juridica';

    if (!CNPJValidator.isValid(pessoa.cnpj)) {
      throw Exception('CNPJ não é valido');
    }

    print('PessoaJuridicaRepository@update ${pessoa.cnpj}');

    //checar se existe
    final pessoaExist = await getByCnpj(pessoa.cnpj);
    if (pessoaExist == null) {
      throw Exception('Esta empresa não esta cadastrada');
    }

    final idPessoa = pessoaExist.id;
    pessoa.idPessoa = idPessoa;
    pessoa.id = idPessoa;
    // 1º Faz o update de pessoas
    await conn
        .table(Pessoa.fqtn)
        .where('id', '=', idPessoa)
        .update(pessoa.toUpdatePessoa());

    // 2º Faz o update de pessoas_juridicas
    await conn
        .table(PessoaJuridica.fqtn)
        .where('idPessoa', '=', idPessoa)
        .update(pessoa.toUpdate());

    // 3º Faz o registro da origem do cadastro de pessoa
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
          end.logradouro, bairro.id, end.cep!,
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

    return idPessoa;
  }

  Future<int> alterarInTransaction(
      int idUsuarioLogado, PessoaJuridica pessoa) async {
    return await db.transaction((ctx) async {
      return await update(idUsuarioLogado, pessoa, connection: ctx);
    });
  }

  Future<dynamic> removeById(int idPessoa, {Connection? connection}) async {
    final conn = connection ?? db;

    final isExist =
        await conn.table(Pessoa.fqtn).where('id', '=', idPessoa).first();
    if (isExist == null) {
      throw Exception('Não existe empresa com este ID ($idPessoa)');
    }

    // Pesquisa pelo id da pessoa na tabela pessoas_origens
    var result = await conn
        .table(PessoaOrigem.fqtn)
        .where('idPessoa', '=', idPessoa)
        .where('sistemaOrigem', '=', BANCO_EMPREGO)
        .where('acao', '=', PessoaOrigem.ACAO_INSERIR)
        .first();

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

    //var enredeco = Endereco.fromMap(result!);

    //Deleta vinculação de endereço com pessoas
    await conn
        .table(PessoaEndereco.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();

    //Deleta telefones da pessoa
    await conn.table(Telefone.fqtn).where('idPessoa', '=', idPessoa).delete();

    //Deleta log de pessoas origens
    await conn
        .table(PessoaOrigem.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();

    //Deleta pessoas_juridicas
    await conn
        .table(PessoaJuridica.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();

    //Deleta pessoa
    await conn.table(Pessoa.fqtn).where('id', '=', idPessoa).delete();
  }

  Future<dynamic> removeAllInTransaction(List<PessoaJuridica> items) async {
    await db.transaction((ctx) async {
      for (final p in items) {
        await removeById(p.idPessoa, connection: ctx);
      }
    });
  }
}
