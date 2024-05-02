import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class ProcessoFavoritoService extends RestServiceBase {
  ProcessoFavoritoService(RestConfig conf) : super(conf);

  String path = '/protocolo/processos/favoritos';

  /// lista todos os Processos Favoritos
  Future<DataFrame<ProcessoFavorito>> all(int numCgm,Filters filtros) async {
    var data = await getDataFrame<ProcessoFavorito>('$path/cgm/$numCgm',
        builder: ProcessoFavorito.fromMap, filtros: filtros);
    return data;
  }

  /// cadastra assunto
  Future<void> insert(ProcessoFavorito item) async {
    await insertEntity(item, path);
  }

  //  app.post('/protocolo/processos/:codProcesso/:anoExercicio',
  Future<void> insertFromProcesso(int codProcesso, String anoExercicio) async {
    var resp = await rawPost(
        conf.getBackendUri('$path/$codProcesso/$anoExercicio'),
        headers: conf.headers);
    if (resp.statusCode != 200) {
      throw Exception(resp.bodyUtf8);
    }
  }

  /// put /protocolo/processos/favoritos
  Future<void> updateById(ProcessoFavorito item) async {
    await updateEntity(item, path);
  }

  Future<void> deleteById(int id) async {
    var uri = conf.getBackendUri('$path/$id');
    final resp = await rawDelete(uri, headers: conf.headers);
    if (resp.statusCode != 200) {
      throw Exception(resp.bodyUtf8);
    }
  }

  /// remove favorito de um processo para um usuario
  Future<void> deleteByProcessoCgm(int codProcesso, String anoExercicio) async {
    ///protocolo/processos/favoritos/:codProcesso/:anoExercicio
    var uri = conf.getBackendUri('$path/$codProcesso/$anoExercicio');
    final resp = await rawDelete(uri, headers: conf.headers);
    if (resp.statusCode != 200) {
      throw Exception(resp.bodyUtf8);
    }
  }
}
