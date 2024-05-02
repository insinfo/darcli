import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class CargoService extends RestServiceBase {
  CargoService(RestConfig conf) : super(conf);

  String path = '/cargos';

  Future<DataFrame<Cargo>> all(Filters filtros) async {
    final data = await getDataFrame<Cargo>(path,
        builder: Cargo.fromMap, filtros: filtros);

    return data;
  }

  Future<Cargo> getById(int id) async {
    return await getEntity<Cargo>('$path/$id', builder: Cargo.fromMap);
  }
}
