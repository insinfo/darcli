import 'package:eloquent/eloquent.dart';
import 'package:rava_core/rava_core.dart';

class GrupoRepository {
  final Connection db;

  GrupoRepository(this.db);

  /// Lista todos os Grupos
  Future<DataFrame<Map<String, dynamic>>> all({Filters? filtros}) async {
    final query = db.table(Grupo.fqtn);
    query.selectRaw('public.grupos.*');

    if (filtros?.searchString != null && filtros?.searchString?.trim() != '') {
      for (var sField in filtros!.searchInFields) {
        if (sField.active) {
          if (sField.operator == 'ilike' || sField.operator == 'like') {
            filtros.searchString = '%${filtros.searchString!.toLowerCase()}%';
            query.whereRaw(
                ''' LOWER(unaccent(${sField.field})) like LOWER(unaccent( ? )) ''',
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
        query.orderBy('grupos.nome');
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

  Future<Map<String, dynamic>?> getByNumeroAsMap(int numero) async {
    final query = db.table(Grupo.fqtn);
    query.where('numero', '=', numero);
    final map = await query.first();
    return map;
  }

  Future<Grupo> getByNumero(int numero) async {
    final map = await getByNumeroAsMap(numero);
    if (map == null) {
      throw Exception('Grupo com numero=$numero não existe!');
    }
    return Grupo.fromMap(map);
  }

  Future<Grupo> insert(Grupo item) async {
    final lastCod =
        await db.table(Grupo.fqtn).selectRaw('MAX(numero) AS cod').first();
    final nextCod = lastCod == null ? 1 : (lastCod['cod'] as int) + 1;
    item.numero = nextCod;

    final query = db.table(Grupo.fqtn);

    await query.insertGetId(item.toInsertMap(), 'numero');
    return item;
  }

  Future<Grupo> update(Grupo item) async {
    final query = db.table(Grupo.fqtn);
    await query.where('numero', '=', item.numero).update(item.toUpdateMap());
    return item;
  }

  Future<void> deleteAll(List<Grupo> items,
      {Connection? connection, void Function(Grupo item)? onDelete}) async {
    final conn = connection ?? db;
    for (final item in items) {
      final query = conn.table(Grupo.fqtn);
      await query.where('numero', '=', item.numero).delete();
      if (onDelete != null) {
        onDelete(item);
      }
    }
  }

  Future<void> deleteAllInTransaction(List<Grupo> items,
      {void Function(Grupo item)? onDelete}) async {
    await db.transaction((ctx) async {
      final res = await deleteAll(items, connection: ctx, onDelete: onDelete);
      return res;
    });
  }
}
