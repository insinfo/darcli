import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class EmpregadorRepository {
  final Connection db;
  EmpregadorRepository(this.db);

  /// lista todos os Empregadores
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Empregador.fqtn);

    query
        .selectRaw('empregadores.*, pessoas.* ')
        .join(Pessoa.fqtn, 'pessoas.id', '=', 'empregadores.idPessoa');

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

  Future<Empregador?> getById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    final data = await getByIdAsMap(id, connection: conn);
    return data != null ? Empregador.fromMap(data) : null;
  }

  Future<Map<String, dynamic>?> getByIdAsMap(int idPessoa,
      {Connection? connection}) async {
    final conn = connection ?? db;

    final query = conn
        .table(Empregador.fqtn)
        .selectRaw(
            'empregadores.*, pessoas.*, divisoes_cnae.nome as "nomeCnae"')
        .where('empregadores.idPessoa', '=', idPessoa);
    query.join(Pessoa.fqtn, 'pessoas.id', '=', 'empregadores.idPessoa');
    query.join(DivisaoCnae.fqtn, 'divisoes_cnae.id', '=',
        'empregadores.idDivisaoCnae');

    final data = await query.first();
    if (data == null) {
      //throw Exception('Pessoa fisica não localizada!');
      return null;
    }

    final tipoPessoa = data['tipo'];
    print('empregador_repository@getByIdAsMap tipoPessoa $tipoPessoa');
    if (tipoPessoa == 'fisica') {
      final pessoaFisica =
          await PessoaFisicaRepository(conn).getByIdAsMap(idPessoa);
      if (pessoaFisica != null) {
        data['pessoaFisica'] = pessoaFisica;
      }
    } else if (tipoPessoa == 'juridica') {
      final pessoaJuridica =
          await PessoaJuridicaRepository(conn).getByIdAsMap(idPessoa);
      if (pessoaJuridica != null) {
        data['pessoaJuridica'] = pessoaJuridica;
      }
    }

    return data;
  }

  Future<int> create(int idUsuarioLogado, Empregador empregador,
      {Connection? connection}) async {
    print('EmpregadorRepository@create');
    final conn = connection ?? db;

    var idPessoa = -1;
    // inserção/alteração caso empregador ser uma pessoa fisica
    if (empregador.isPessoaFisica) {
      final pessoaFisica = empregador.toPessoaFisica();
      pessoaFisica.cpf = pessoaFisica.cpf.replaceAll(RegExp('[^0-9]'), '');
      final pFisicaRepo = PessoaFisicaRepository(conn);
      final exist = await pFisicaRepo.isExistByCpf(pessoaFisica.cpf);

      if (exist) {
        idPessoa = await pFisicaRepo.update(idUsuarioLogado, pessoaFisica);
      } else {
        idPessoa = await pFisicaRepo.create(idUsuarioLogado, pessoaFisica);
      }
    }
    // inserção/alteração caso empregador ser uma pessoa juridica
    else if (empregador.isPessoaJuridica) {
      final pessoaJuridica = empregador.toPessoaJuridica();
      pessoaJuridica.cnpj =
          pessoaJuridica.cnpj.replaceAll(RegExp('[^0-9]'), '');
      final pJuridicaRepo = PessoaJuridicaRepository(conn);
      final exist = await pJuridicaRepo.isExistByCnpj(pessoaJuridica.cnpj);

      if (exist) {
        print('EmpregadorRepository@create juridica alterar');
        idPessoa = await pJuridicaRepo.update(idUsuarioLogado, pessoaJuridica);
      } else {
        print('EmpregadorRepository@create juridica incluir');
        idPessoa = await pJuridicaRepo.create(idUsuarioLogado, pessoaJuridica,
            checkIsExist: false);
      }
    } else {
      throw Exception('tipo de Pessoa desconhecido');
    }

    //bloco de inserção/alteração da tabela empregador
    empregador.idPessoa = idPessoa;

    final query = conn.table(Empregador.fqtn);
    // A data de cadastro é a data atual
    empregador.dataCadastroEmpregador = DateTime.now();
    await query.insert(empregador.toInsertMap());

    //verifica se vem de Empregador web
    print(
        'EmpregadorRepository@create empregador.isFromWeb ${empregador.isFromWeb}');
    if (empregador.isFromWeb == true) {
      final empregadorWebRepository = EmpregadorWebRepository(conn);
      await empregadorWebRepository.validar(
          empregador.cpfOrCnpj!, idUsuarioLogado);
      if (empregador.observacaoValidacao != null) {
        await empregadorWebRepository.updateObservacaoValidacao(
            empregador.cpfOrCnpj!, empregador.observacaoValidacao!);
      }
    }

    return idPessoa;
  }

  Future<int> createInTransaction(
      int idUsuarioLogado, Empregador empregador) async {
    return await db.transaction((ctx) async {
      return await create(idUsuarioLogado, empregador, connection: ctx);
    });
  }

  Future<bool> isExisteByIdPessoa(int idPessoa,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final data = await conn
        .table(Empregador.fqtn)
        .where('idPessoa', '=', idPessoa)
        .first();

    if (data == null) {
      return false;
    }
    return true;
  }

  Future<bool> isExisteByCpfOrCnpj(String cpfOrCnpj, String tipoPessoa,
      {Connection? connection}) async {
    var conn = connection ?? db;
    Map<String, dynamic>? data;
    if (tipoPessoa.toLowerCase() == 'fisica') {
      data = await conn
          .table(Empregador.fqtn)
          .selectRaw('${Empregador.tableName}.*')
          .join(
              PessoaFisica.fqtn,
              '${PessoaFisica.tableName}.${PessoaFisica.idPessoaCol}',
              '=',
              '${Empregador.tableName}.${Empregador.idPessoaCol}')
          .where('${PessoaFisica.tableName}.${PessoaFisica.cpfCol}', '=',
              cpfOrCnpj)
          .first();
    } else if (tipoPessoa.toLowerCase() == 'juridica') {
      data = await conn
          .table(Empregador.fqtn)
          .selectRaw('${Empregador.tableName}.*')
          .join(
              PessoaJuridica.fqtn,
              '${PessoaJuridica.tableName}.${PessoaJuridica.idPessoaCol}',
              '=',
              '${Empregador.tableName}.${Empregador.idPessoaCol}')
          .where('${PessoaJuridica.tableName}.${PessoaJuridica.cnpjCol}', '=',
              cpfOrCnpj)
          .first();
    }

    if (data == null) {
      return false;
    }
    return true;
  }

  /// retorna um Map se existir se não retorna nulo
  Future<Map<String, dynamic>?> isExisteByCpfOrCnpjAsMap(
      String cpfOrCnpj, String tipoPessoa,
      {Connection? connection}) async {
    var conn = connection ?? db;
    Map<String, dynamic>? data;
    if (tipoPessoa.toLowerCase() == 'fisica') {
      data = await conn
          .table(Empregador.fqtn)
          .selectRaw('${Empregador.tableName}.*')
          .join(
              PessoaFisica.fqtn,
              '${PessoaFisica.tableName}.${PessoaFisica.idPessoaCol}',
              '=',
              '${Empregador.tableName}.${Empregador.idPessoaCol}')
          .where('${PessoaFisica.tableName}.${PessoaFisica.cpfCol}', '=',
              cpfOrCnpj)
          .first();
    } else if (tipoPessoa.toLowerCase() == 'juridica') {
      data = await conn
          .table(Empregador.fqtn)
          .selectRaw('${Empregador.tableName}.*')
          .join(
              PessoaJuridica.fqtn,
              '${PessoaJuridica.tableName}.${PessoaJuridica.idPessoaCol}',
              '=',
              '${Empregador.tableName}.${Empregador.idPessoaCol}')
          .where('${PessoaJuridica.tableName}.${PessoaJuridica.cnpjCol}', '=',
              cpfOrCnpj)
          .first();
    }

    return data;
  }

  Future<void> updateInTransaction(
    int idUsuarioLogado,
    Empregador empregador,
  ) async {
    await db.transaction((ctx) async {
      await update(idUsuarioLogado, empregador, connection: ctx);
    });
  }

  Future<void> update(int idUsuarioLogado, Empregador empregador,
      {Connection? connection}) async {
    final conn = connection ?? db;

    if (empregador.idPessoa == -1) {
      throw Exception('Empregador.id não pode ser nulo ou -1');
    }

    await conn
        .table(Empregador.fqtn)
        .where('idPessoa', '=', empregador.idPessoa)
        .update(empregador.toUpdateMap());

    if (empregador.isPessoaFisica) {
      await PessoaFisicaRepository(conn)
          .update(idUsuarioLogado, empregador.pessoaFisica!);
    } else if (empregador.isPessoaJuridica) {
      await PessoaJuridicaRepository(conn)
          .update(idUsuarioLogado, empregador.pessoaJuridica!);
    } else {
      throw Exception('tipo de Pessoa desconhecido');
    }
  }

  Future<void> removeById(int idPessoa,
      {Connection? connection, bool removePessoa = false}) async {
    final conn = connection ?? db;

    await conn.table(Empregador.fqtn).where('idPessoa', '=', idPessoa).delete();

    if (removePessoa) {
      final emp = await getById(idPessoa);
      if (emp == null) {
        throw Exception('Empregador com este idPessoa $idPessoa não existe');
      }
      if (emp.isPessoaFisica) {
        await PessoaFisicaRepository(conn).removeById(idPessoa);
      } else if (emp.isPessoaJuridica) {
        await PessoaJuridicaRepository(conn).removeById(idPessoa);
      }
    }
  }

  Future<void> removeAll(List<Empregador> itens,
      {Connection? connection}) async {
    final conn = connection ?? db;

    for (var item in itens) {
      await removeById(item.idPessoa, connection: conn);
    }
  }

  Future<void> removeAllInTransaction(List<Empregador> itens) async {
    await db.transaction((ctx) async {
      await removeAll(itens, connection: ctx);
    });
  }
}
