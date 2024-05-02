import 'package:excel/excel.dart';
import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class CursoRepository {
  final Connection db;
  CursoRepository(this.db);

  /// lista todos os Cursos
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query = db.table(Curso.fqtn);
    query.selectRaw(''' 
    cursos.*
     ${ filtros?.idVaga != null ? ',vagas_cursos.obrigatorio' :'' }
     ''');

    if (filtros?.idVaga != null) {
      query.join(VagaCurso.fqtn, VagaCurso.idCursoFqCol, '=', Curso.idFqCol);
      query.where(VagaCurso.idVagaFqCol, '=', filtros!.idVaga);
    }

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
        query.orderBy(Curso.nameCol);
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
    final query = db.table(Curso.fqtn).selectRaw('*').where('id', '=', id);
    final data = await query.first();
    if (data == null) {
      throw Exception('Não encontrado com o id = $id');
    }
    return data;
  }

  Future<int> create(Curso item, {Connection? connection}) async {
    final conn = connection ?? db;

    final isExist = await conn.table(Cargo.fqtn).whereRaw(
        ' Lower(unaccent(${Cargo.nameCol})) = unaccent( ? ) ',
        [item.nome.toLowerCase().trim()]).first();

    if (isExist != null) {
      throw Exception('Já existe este curso!');
    }

    item.nome = item.nome.trim().toTitleCase();

    await conn.table(Curso.fqtn).insert(item.toInsertMap());
    return item.id;
  }

  Future<void> importXlsx(List<int> xlsxFileBytes) async {
    final excel = Excel.decodeBytes(xlsxFileBytes);
    final defaultSheet = excel[excel.getDefaultSheet()!];

    for (var i = 0; i < defaultSheet.rows.length; i++) {
      final cell = defaultSheet.rows[i].first;

      if (i > 0) {
        if (cell != null && cell.value is TextCellValue) {
          try {
            var nome = (cell.value as TextCellValue).value;
            nome = nome.toTitleCase().trim();

            var tipoCurso = '';
            if (nome.toLowerCase().contains('engenharia')) {
              tipoCurso = 'Superior';
            } else if (nome.toLowerCase().contains('bacharelado')) {
              tipoCurso = 'Superior';
            } else if (nome.toLowerCase().contains('superior')) {
              tipoCurso = 'Superior';
            } else if (nome.toLowerCase().contains('técnico')) {
              tipoCurso = 'Técnico';
            } else if (nome.toLowerCase().contains('tecnico')) {
              tipoCurso = 'Técnico';
            } else if (nome.toLowerCase().contains('doutorado')) {
              tipoCurso = 'Doutorado';
            } else if (nome.toLowerCase().contains('mestrado')) {
              tipoCurso = 'Mestrado';
            } else if (nome.toLowerCase().contains('pos-gra')) {
              tipoCurso = 'Pos-graduação';
            } else if (nome.toLowerCase().contains('lato sensu')) {
              tipoCurso = 'Pos-graduação';
            } else if (nome.toLowerCase().contains('stricto sensu')) {
              tipoCurso = 'Pos-graduação';
            } else if (nome.toLowerCase().contains('mba')) {
              tipoCurso = 'Pos-graduação';
            }

            if (nome
                .toLowerCase()
                .startsWith('curso superior de tecnologia em')) {
              nome = nome.substring(31);
            } else if (nome.toLowerCase().startsWith('curso superior de')) {
              nome = nome.substring(17);
            } else if (nome.toLowerCase().startsWith('curso de')) {
              nome = nome.substring(8);
            } else if (nome.toLowerCase().startsWith('curso ')) {
              nome = nome.substring(6);
            } else if (nome.toLowerCase().startsWith('técnico em ')) {
              nome = nome.substring(11);
            } else if (nome.toLowerCase().startsWith('curso técnico em ')) {
              nome = nome.substring(17);
            }

            final curso =
                Curso(id: -1, nome: nome.trim(), tipoCurso: tipoCurso);
            await create(curso);
          } catch (e) {
            print('importXlsx error $e');
          }
        }
      }
    }
  }

  Future<void> update(Curso item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(Curso.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(Curso.fqtn).where(Curso.idCol, '=', id).delete();
  }

  Future<void> removeByIdInTransaction(int id) async {
    await db.transaction((ctx) async {
      await removeById(id, connection: ctx);
    });
  }

  Future<void> removeAllInTransaction(List<Curso> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }
}
