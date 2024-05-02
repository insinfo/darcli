import 'package:excel/excel.dart';
import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class CargoRepository {
  final Connection db;
  CargoRepository(this.db);

  /// lista todos os cargos
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Cargo.fqtn);

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
        query.orderBy(Cargo.nameCol);
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
    final query = db.table(Cargo.fqtn).selectRaw('*').where('id', '=', id);
    final data = await query.first();
    if (data == null) {
      throw Exception('Não encontrado com o id = $id');
    }
    return data;
  }

  Future<int> create(Cargo item, {Connection? connection}) async {
    final conn = connection ?? db;

    final isExist = await conn.table(Cargo.fqtn).whereRaw(
        ' Lower(unaccent(${Cargo.nameCol})) = unaccent( ? ) ',
        [item.nome.toLowerCase().trim()]).first();

    if (isExist != null) {
      throw Exception('Já existe este cargo!');
    }

    item.nome = item.nome.trim().toTitleCase();

    await conn.table(Cargo.fqtn).insert(item.toInsertMap());
    return item.id;
  }

  //
  Future<void> importXlsx(List<int> xlsxFileBytes) async {
    final excel = Excel.decodeBytes(xlsxFileBytes);
    final defaultSheet = excel[excel.getDefaultSheet()!];

    for (var i = 0; i < defaultSheet.rows.length; i++) {
      final cell = defaultSheet.rows[i].first;

      if (i > 0) {
        if (cell != null && cell.value is TextCellValue) {
          try {
            var nome = (cell.value as TextCellValue).value;
            nome = nome.toTitleCase();
            final cargo = Cargo(id: -1, nome: nome);
            await create(cargo);
          } catch (e) {
            print('importXlsx error $e');
          }
        }
      }
    }
  }

  Future<void> update(Cargo item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Cargo.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(Cargo.fqtn).where(Cargo.idCol, '=', id).delete();
  }

  Future<void> removeByIdInTransaction(int id) async {
    await db.transaction((ctx) async {
      await removeById(id, connection: ctx);
    });
  }

  Future<void> removeAllInTransaction(List<Cargo> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }
}
