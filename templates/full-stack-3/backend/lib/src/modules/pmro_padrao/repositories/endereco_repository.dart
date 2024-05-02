import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class EnderecoRepository {
  final Connection db;

  EnderecoRepository(this.db);

  /// lista todos os endereços
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Endereco.fqtn);

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
        //query.orderBy('nome');
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

  Future<int> create(Endereco item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Endereco.fqtn);
    item.id = await query.insertGetId(item.toInsertMap());
    return item.id;
  }

  Future<void> update(Endereco item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Endereco.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(Endereco.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAllInTransaction(List<Endereco> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }

  Future<Endereco?> getByLogradouroIdBairroCep(
      String logradouro, int idBairro, String cep,
      {Connection? connection}) async {
    final conn = connection ?? db;

    // $sql = 'SELECT * FROM "enderecos" ';
    // $sql .= ' where "idBairro" = \''.$idBairro.'\' ';
    // $sql .= ' and "cep" = \''.$cep.'\' ';
    // $sql .= ' and "logradouro" ilike '.$this->db->escape('%'.trim($logradouro).'%').';';

    final data = await conn
        .table(Endereco.fqtn)
        .where('idBairro', '=', idBairro)
        .where('cep', '=', cep)
        .whereRaw('unaccent(lower(trim(logradouro))) like unaccent( ? )',
            [logradouro.trim().toLowerCase()]).first();

    if (data == null) {
      return null;
    }
    return Endereco.fromMap(data);
  }
}
