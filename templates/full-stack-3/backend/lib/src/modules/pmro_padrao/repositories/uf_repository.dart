import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class UfRepository {
  final Connection db;
  UfRepository(this.db);

  /// lista todos os estados
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Uf.fqtn);

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

    if (filtros?.idPais != null) {
      query.where('idPais', '=', filtros!.idPais);
    } else {
      query.where('idPais', '=', ID_PAIS);
    }

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      if (totalRecords > 1) {
        query.orderBy('sigla');
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

  Future<Map<String, dynamic>?> getByIdAsMap(int id) async {
    final query = db.table(Uf.fqtn).selectRaw('*').where('id', '=', id);
    final data = await query.first();
    // if (data == null) {
    //   throw Exception('Não encontrado com o id = $id');
    // }
    return data;
  }

  Future<int> create(Uf item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Uf.fqtn);
    await query.insert(item.toInsertMap());
    return item.id;
  }

  Future<void> update(Uf item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Uf.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(Uf.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAllInTransaction(List<Uf> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }
}
