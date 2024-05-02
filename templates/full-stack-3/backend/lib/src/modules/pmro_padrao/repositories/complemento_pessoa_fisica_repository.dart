import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class ComplementoPessoaFisicaRepository {
  final Connection db;

  ComplementoPessoaFisicaRepository(this.db);

  /// lista todos os Complemento de Pessoa Fisica
  Future<DataFrame<Map<String, dynamic>>> listar({Filters? filtros}) async {
    final query = db.table(ComplementoPessoaFisica.fqtn);

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

  Future<int> create(ComplementoPessoaFisica item,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(ComplementoPessoaFisica.fqtn);
    await query.insert(item.toInsertMap());
    return item.idPessoa;
  }

  Future<void> update(ComplementoPessoaFisica item,
      {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn
        .table(ComplementoPessoaFisica.fqtn)
        .where('idPessoa', '=', item.idPessoa);
    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int idPessoa, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn
        .table(ComplementoPessoaFisica.fqtn)
        .where('idPessoa', '=', idPessoa)
        .delete();
  }

  Future<void> removeAllInTransaction(
      List<ComplementoPessoaFisica> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.idPessoa, connection: ctx);
      }
    });
  }
}
