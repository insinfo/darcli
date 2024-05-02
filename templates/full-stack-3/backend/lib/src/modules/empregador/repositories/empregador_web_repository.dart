import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class EmpregadorWebRepository {
  final Connection db;
  EmpregadorWebRepository(this.db);

  /// lista todos
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(EmpregadorWeb.fqtn);
    query.selectRaw('''${EmpregadorWeb.tableName}.*, 
        ${DivisaoCnae.tableName}.${DivisaoCnae.nomeCol} as "nomeCnae",
        ${Pessoa.nomeFqCol} AS "nomeRespValidacao"
        ''');
    // pega nome da divisão CNAE
    query.join(
        DivisaoCnae.fqtn,
        '${DivisaoCnae.tableName}.${DivisaoCnae.idCol}',
        '=',
        '${EmpregadorWeb.tableName}.${EmpregadorWeb.idCnaeCol}');
    //
    query.join(Pessoa.fqtn, Pessoa.idFqCol, '=',
        EmpregadorWeb.usuarioRespValidacaoFqCol, 'left');

    if (filtros?.statusValidacao != null) {
      query.where(
          EmpregadorWeb.statusValidacaoFqCol, '=', filtros!.statusValidacao);
    }

    if (filtros?.searchString != null && filtros?.searchString?.trim() != '') {
      for (var filtroItem in filtros!.searchInFields) {
        var field = filtroItem.field;
        final fieldsValidos = ['nome', 'cpfOrCnpj'];
        if (fieldsValidos.contains(filtroItem.field)) {
          field = '${EmpregadorWeb.tableName}.${filtroItem.field}';
        }
        if (filtroItem.active) {
          if (filtroItem.operator == 'ilike' || filtroItem.operator == 'like') {
            filtros.searchString = '%${filtros.searchString!.toLowerCase()}%';
            query.whereRaw(''' LOWER(unaccent(${field})) like unaccent( ? ) ''',
                [filtros.searchString]);
          } else {
            query.where(field, filtroItem.operator, filtros.searchString);
          }
        }
      }
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      if (totalRecords > 1) {
        query.orderBy(
            '${EmpregadorWeb.tableName}.${EmpregadorWeb.idCol}', 'desc');
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

  Future<Map<String, dynamic>> getByIdAsMap(int id) async {
    final query =
        db.table(EmpregadorWeb.fqtn).selectRaw('*').where('id', '=', id);
    final data = await query.first();
    if (data == null) {
      throw Exception('Não encontrado com o id = $id');
    }
    return data;
  }

  Future<EmpregadorWeb> getByCpfOrCnpj(String cpfOrCnpj) async {
    final query = db
        .table(EmpregadorWeb.fqtn)
        .selectRaw('*')
        .where('cpfOrCnpj', '=', CPFValidator.strip(cpfOrCnpj));
    final map = await query.first();
    if (map == null) {
      throw NotFoundException(
          message: 'Não encontrado com o cpfOrCnpj = $cpfOrCnpj');
    }
    return EmpregadorWeb.fromMap(map);
  }

  Future<Map<String, dynamic>> getByCpfOrCnpjAsMap(String cpfOrCnpj) async {
    final query = db
        .table(EmpregadorWeb.fqtn)
        .selectRaw('*')
        .where('cpfOrCnpj', '=', CPFValidator.strip(cpfOrCnpj));
    final data = await query.first();
    if (data == null) {
      throw NotFoundException(
          message: 'Não encontrado com o cpfOrCnpj = $cpfOrCnpj');
    }
    return data;
  }

  Future<int> create(EmpregadorWeb item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(EmpregadorWeb.fqtn);
    item.cpfOrCnpj = item.cpfOrCnpj.replaceAll(RegExp(r'[^0-9]'), '');
    await query.insert(item.toInsertMap());
    return item.id;
  }

  Future<void> createInTransaction(EmpregadorWeb item) async {
    await db.transaction((ctx) async {
      await create(item, connection: ctx);
    });
  }

  Future<void> update(EmpregadorWeb item, {Connection? connection}) async {
    final conn = connection ?? db;
    item.cpfOrCnpj = item.cpfOrCnpj.replaceAll(RegExp(r'[^0-9]'), '');
    final query = conn.table(EmpregadorWeb.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  /// define um EmpregadorWeb como Validado
  Future<void> validar(String cpfOrCnpj, int idUsuarioRespValidacao,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final query =
        conn.table(EmpregadorWeb.fqtn).where('cpfOrCnpj', '=', cpfOrCnpj);
    await query.update({
      'statusValidacao': EmpregadorStatusValidacao.validado.value,
      'dataValidacao': DateTime.now(),
      'usuarioRespValidacao': idUsuarioRespValidacao
    });
  }

  Future<void> updateStatus(EmpregadorWeb emp, {Connection? connection}) async {
    final conn = connection ?? db;
    final query =
        conn.table(EmpregadorWeb.fqtn).where('cpfOrCnpj', '=', emp.cpfOrCnpj);
    await query.update({
      'statusValidacao': emp.statusValidacao?.value,
      'observacaoValidacao': emp.observacaoValidacao,
    });
  }

  Future<void> updateObservacaoValidacao(
      String cpfOrCnpj, String observacaoValidacao,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final query =
        conn.table(EmpregadorWeb.fqtn).where('cpfOrCnpj', '=', cpfOrCnpj);
    await query.update({
      'observacaoValidacao': observacaoValidacao,
    });
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(EmpregadorWeb.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAllInTransaction(List<EmpregadorWeb> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }
}
