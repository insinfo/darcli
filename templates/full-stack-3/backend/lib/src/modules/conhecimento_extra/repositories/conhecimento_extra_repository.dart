import 'package:sibem_backend/sibem_backend.dart';
import 'package:eloquent/eloquent.dart';

class ConhecimentoExtraRepository {
  final Connection db;
  ConhecimentoExtraRepository(this.db);

  /// lista todos os conhecimento extras
  Future<DataFrame<Map<String, dynamic>>> getAll({Filters? filtros}) async {
    final query =
        db.table(ConhecimentoExtra.fqtn).selectRaw('''conhecimentos_extras.*, 
     tipos_conhecimentos.nome as "tipoConhecimentoNome"  
     ${ filtros?.idVaga != null ? ',vagas_conhecimentos_extras.obrigatorio' :'' }
    ''');

    query.join(TipoConhecimento.fqtn, 'tipos_conhecimentos.id', '=',
        'conhecimentos_extras.idTipoConhecimento');

    if (filtros?.idVaga != null) {
      query.join(VagaConhecimentoExtra.fqtn, VagaConhecimentoExtra.idConhecimentoExtraFqCol, '=', ConhecimentoExtra.idFqCol);
      query.where(VagaConhecimentoExtra.idVagaFqCol, '=', filtros!.idVaga);
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

  Future<ConhecimentoExtra?> getById(int id) async {
    final data = await getByIdAsMap(id);
    return data != null ? ConhecimentoExtra.fromMap(data) : null;
  }

  Future<Map<String, dynamic>?> getByIdAsMap(int id) async {
    final query = db.table(ConhecimentoExtra.fqtn).selectRaw('''* ''');

    // query.join(TipoConhecimento.fqtn, 'tipos_conhecimentos.id', '=',
    //     'conhecimentos_extras.idTipoConhecimento');

    query.where('id', '=', id);

    final data = await query.first();

    if (data == null) {
      //throw Exception('Não encontrado Conhecimento Extra com o id = $id');
      return null;
    }

    //Obter tipoConhecimento
    final tipoConhecimento = await db
        .table(TipoConhecimento.fqtn)
        .selectRaw('tipos_conhecimentos.*')
        .join(ConhecimentoExtra.fqtn, 'conhecimentos_extras.idTipoConhecimento',
            '=', 'tipos_conhecimentos.id')
        .where('conhecimentos_extras.id', '=', id)
        .first();

    if (tipoConhecimento != null) {
      data['tipoConhecimento'] = tipoConhecimento;
      data['tipoConhecimentoNome'] = tipoConhecimento['nome'];
    }

    return data;
  }

  Future<int> create(ConhecimentoExtra item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(ConhecimentoExtra.fqtn);
    await query.insert(item.toInsertMap());
    return item.id;
  }

  Future<void> update(ConhecimentoExtra item, {Connection? connection}) async {
    final conn = connection ?? db;
    final query = conn.table(ConhecimentoExtra.fqtn).where('id', '=', item.id);
    await query.update(item.toUpdateMap());
  }

  Future<void> removeById(int id, {Connection? connection}) async {
    final conn = connection ?? db;
    await conn.table(ConhecimentoExtra.fqtn).where('id', '=', id).delete();
  }

  Future<void> removeAllInTransaction(List<ConhecimentoExtra> items) async {
    await db.transaction((ctx) async {
      for (final item in items) {
        await removeById(item.id, connection: ctx);
      }
    });
  }
}
