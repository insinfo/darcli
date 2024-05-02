import 'package:esic_core/esic_core.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

class UsuarioRepository {
  final DbLayer db;
  UsuarioRepository(this.db);

  Future<DataFrame<Map<String, dynamic>>> getAllAsMap(
      {Filters? filtros}) async {
    var query = db.select().fieldRaw('''
    sis_usuario.*
    ''').from('sis_usuario');

    if (filtros?.isSearch == true) {
      query.whereGroup((q) {
        for (var sField in filtros!.searchInFields) {
          if (sField.active) {
            if (sField.operator == 'ilike' || sField.operator == 'like') {
              var substitutionField = sField.field;
              if (sField.field.contains('.')) {
                substitutionField = sField.field.split('.').last;
              }
              var substitutionValues = {
                substitutionField: '%${filtros.searchString?.toLowerCase()}%',
              };

              q.whereRaw(
                  'LOWER(${db.putInQuotes(sField.field)}::text) like ${db.formatSubititutioValue(sField.field)}',
                  andOr: 'OR',
                  substitutionValues: substitutionValues);
            } else {
              q.orWhereSafe(
                  '"${sField.field}"', sField.operator, filtros.searchString);
            }
          }
        }
        return q;
      });
    }
    // print(query.toSql());
    final totalRecords = await query.count();

    if (filtros?.isOrder == true) {
      query.order(filtros!.orderBy!,
          dir: filtros.orderDir == 'asc' ? SortOrder.ASC : SortOrder.DESC);
    } else {
      // query.order('datacadastro', dir: SortOrder.DESC);
    }

    if (filtros?.isLimit == true) {
      query.limit(filtros!.limit!);
    }
    if (filtros?.isOffset == true) {
      query.offset(filtros!.offset!);
    }

    //print(query.toSql());
    var dados = await query.getAsMap();

    return DataFrame<Map<String, dynamic>>(
      items: dados,
      totalRecords: totalRecords,
    );
  }

  Future<Map<String, dynamic>> getById(int id) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('sis_usuario')
        .whereSafe('idusuario', '=', id)
        .limit(1);

    var dados = await query.getAsMap();

    if (dados.isNotEmpty == true) {
      var data = dados[0];
      return data;
    }
    throw Exception('Not found');
  }

  Future<Map<String, dynamic>> getByCpfAsMap(String cpf) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('sis_usuario')
        .whereSafe('cpfusuario', '=', cpf)
        .limit(1);

    var dados = await query.getAsMap();

    if (dados.isNotEmpty == true) {
      var data = dados[0];
      return data;
    }
    throw Exception('Not found');
  }

  Future<Usuario> getByCpf(String cpf) async {
    return Usuario.fromMap(await getByCpfAsMap(cpf));
  }

  Future<int> insert(Usuario item, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    final map = item.toDbInsert();
    var query = com
        .insertGetId(defaultIdColName: 'idusuario')
        .into('sis_usuario')
        .setAll(map);
    final resp = await query.exec();
    final id = resp.first.first;
    return id;
  }

  Future<void> update(Usuario item, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    //atualiza fac
    await com
        .update()
        .table('sis_usuario')
        .setAll(item.toDbUpdate())
        .whereSafe('idusuario', '=', item.id)
        .exec();
  }

  Future<void> delete(Usuario item) async {
    await deleteById(item.id);
  }

  Future<void> deleteById(int id) async {
    await db.delete().from('sis_usuario').where('idusuario=?', id).exec();
  }

  Future<void> deleteAllByIds(List<int> ids) async {
    for (var id in ids) {
      await deleteById(id);
    }
  }

  Future<void> deleteAll(List<Usuario> items) async {
    for (var item in items) {
      await delete(item);
    }
  }
}
