import 'package:eloquent/eloquent.dart';
import 'package:sibem_backend/sibem_backend.dart';

class BairroRepository {
  final Connection db;

  BairroRepository(this.db);

  /// lista todos os bairros
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Bairro.fqtn);

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
    if (filtros?.idCidade != null) {
      query.where('idMunicipio', '=', filtros!.idCidade);
    }

    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.orderBy(filtros!.orderBy!, filtros.orderDir!);
    } else {
      if (totalRecords > 1) {
        query.orderBy('nome');
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

  Future<int> create(Bairro item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Bairro.fqtn);
    item.id = await query.insertGetId(item.toInsertMap());
    return item.id;
  }

  Future<void> update(Bairro item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Bairro.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(Bairro.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAllInTransaction(List<Bairro> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }

  Future<Bairro?> getByNomeAndIdMunicipio(String nomeBairro, int idMunicipio,
      {Connection? connection}) async {
    final conn = connection ?? db;
//  'SELECT * FROM "bairros" where "idMunicipio" = \''.$idMunicipio.'\' and nome ilike '.$this->db->escape('%'.trim($nome).'%').';';
    final data = await conn
        .table(Bairro.fqtn)
        .where('idMunicipio', '=', idMunicipio)
        .whereRaw('unaccent(lower(trim(nome))) like unaccent( ? )',
            [nomeBairro.trim().toLowerCase()]).first();

    if (data == null) {
      return null;
    }
    return Bairro.fromMap(data);
  }
}