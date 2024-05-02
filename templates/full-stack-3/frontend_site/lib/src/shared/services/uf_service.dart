import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class UfService extends RestServiceBase {
  UfService(RestConfig conf) : super(conf);

  String path = '/ufs';

  Future<DataFrame<Uf>> all(Filters filtros) async {
    final data =
        await getDataFrame<Uf>(path, builder: Uf.fromMap, filtros: filtros);
    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        data[i].nome = data[i].nome.toTitleCase();
      }
    }

    return data;
  }

  Future<Uf> getById(int id) async {
    return await getEntity<Uf>('$path/$id', builder: Uf.fromMap);
  }
}
