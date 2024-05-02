import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class AcaoFavoritaService extends RestServiceBase {
  AcaoFavoritaService(RestConfig conf) : super(conf);
  
  bool isLoadFavoritos = false;
  DataFrame<AcaoFavorita> favoritos = DataFrame.newClear();

  String path = '/protocolo/acoes/favoritas';

  /// lista todas as Ações Favoritas
  Future<DataFrame<AcaoFavorita>> all(int numCgm,Filters filtros) async {
    var data = await getDataFrame<AcaoFavorita>('$path/cgm/$numCgm',
        builder: AcaoFavorita.fromMap, filtros: filtros);
    return data;
  }

  /// cadastra assunto
  Future<void> insert(AcaoFavorita item) async {
    await insertEntity(item, path);
  }

  //
  Future<void> insertFromAcao(int codAcao) async {
    var resp = await rawPost(conf.getBackendUri('$path/$codAcao'),
        headers: conf.headers);
    if (resp.statusCode != 200) {
      throw Exception(resp.bodyUtf8);
    }
  }

  ///
  Future<void> updateById(AcaoFavorita item) async {
    await updateEntity(item, path);
  }

  Future<void> deleteById(int id) async {
    var uri = conf.getBackendUri('$path/$id');
    final resp = await rawDelete(uri, headers: conf.headers);
    if (resp.statusCode != 200) {
      throw Exception(resp.bodyUtf8);
    }
  }

  /// remove acao favorita  para um usuario
  Future<void> deleteByAcaoCgm(int codAcao) async {
    var uri = conf.getBackendUri('$path/$codAcao');
    final resp = await rawDelete(uri, headers: conf.headers);
    if (resp.statusCode != 200) {
      throw Exception(resp.bodyUtf8);
    }
  }
}
