import 'package:esic_core/esic_core.dart';
import 'package:fluent_query_builder/fluent_query_builder.dart';

class AnexoRepository {
  final DbLayer db;
  AnexoRepository(this.db);

  Future<Map<String, dynamic>> getById(int idanexo) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_anexo')
        .whereSafe('idanexo', '=', idanexo)
        .limit(1);
    var dados = await query.getAsMap();
    if (dados.isNotEmpty == true) {
      var data = dados[0];
      return data;
    }
    throw Exception('Not found');
  }

  Future<Map<String, dynamic>> getByIdSolicitacao(int idsolicitacao) async {
    var query = db
        .select()
        .fieldRaw('*')
        .from('lda_anexo')
        .whereSafe('idsolicitacao', '=', idsolicitacao)
        .limit(1);
    var dados = await query.getAsMap();
    if (dados.isNotEmpty == true) {
      var data = dados[0];
      return data;
    }
    throw Exception('Not found');
  }

  Future<int> insert(Anexo item, {DbLayer? connection}) async {
    var com = connection != null ? connection : db;
    final map = item.toDbInsert();
    var query = com
        .insertGetId(defaultIdColName: 'idanexo')
        .into('lda_anexo')
        .setAll(map);
    final resp = await query.exec();
    final id = resp.first.first;
    return id;
  }

  Future<void> deleteById(int idanexo) async {
    await db.delete().from('lda_anexo').where('idanexo=?', idanexo).exec();
  }
}
