import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class MunicipioService extends RestServiceBase {
  MunicipioService(RestConfig conf) : super(conf);

  String path = '/municipios';

  Future<DataFrame<Municipio>> all(Filters filtros) async {
    final data = await getDataFrame<Municipio>(path,
        builder: Municipio.fromMap, filtros: filtros);

    return data;
  }

  Future<DataFrame<Municipio>> getAllByIdUf(int idUf) async {
    return await getDataFrame<Municipio>('$path/uf/id/$idUf',
        builder: Municipio.fromMap);
  }
}
