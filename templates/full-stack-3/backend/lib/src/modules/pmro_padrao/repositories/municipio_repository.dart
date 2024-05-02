import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class MunicipioRepository {
  final Connection db;

  MunicipioRepository(this.db);

  /// lista todos os municipio
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Municipio.fqtn);

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

  Future<DataFrame<Map<String, dynamic>>> getAllBySiglaUf(String siglaUf,
      {Connection? connection}) async {
    final conn = connection ?? db;

    final dados = await conn
        .table(Municipio.fqtn)
        .whereRaw( 'Lower(municipios.siglaUF) = ? ',[siglaUf.toLowerCase()])
        .orderBy('nome')
        .get();

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: dados.length,
    );
  }

  Future<DataFrame<Map<String, dynamic>>> getAllByIdUf(int idUf,
      {Connection? connection}) async {
    final conn = connection ?? db;

    final dados = await conn
        .table(Municipio.fqtn)
        .where('municipios.idUF', '=', idUf)
        .orderBy('nome')
        .get();

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: dados.length,
    );
  }

  Future<Municipio> getById(int id, {Connection? connection}) async {
    final conn = connection ?? db;

    final data = await conn
        .table(Municipio.fqtn)
        .where('municipios.id', '=', id)
        .orderBy('nome')
        .first();
    if (data == null) {
      throw Exception('Municipio com id=$id não encontrado');
    }

    return Municipio.fromMap(data);
  }

  Future<Map<String, dynamic>?> getByIdAsMap(int id,
      {Connection? connection}) async {
    final conn = connection ?? db;

    final data = await conn
        .table(Municipio.fqtn)
        .where('municipios.id', '=', id)
        .orderBy('nome')
        .first();

    return data;
  }

  Future<int> create(Municipio item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Municipio.fqtn);
    await query.insert(item.toInsertMap());
    return item.id;
  }

  Future<void> update(Municipio item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Municipio.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(Municipio.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAllInTransaction(List<Municipio> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }
}
