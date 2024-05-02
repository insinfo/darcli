import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class EscolaridadeService extends RestServiceBase {
  EscolaridadeService(RestConfig conf) : super(conf);

  String path = '/escolaridades';

  Future<DataFrame<Escolaridade>> all(Filters filtros) async {
    final data = await getDataFrame<Escolaridade>(path,
        builder: Escolaridade.fromMap, filtros: filtros);

    return data;
  }

  Future<Escolaridade> getById(int id) async {
    return await getEntity<Escolaridade>('$path/$id',
        builder: Escolaridade.fromMap);
  }
}
