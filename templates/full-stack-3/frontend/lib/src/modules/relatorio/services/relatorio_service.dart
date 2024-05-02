import 'package:sibem_frontend/sibem_frontend.dart';

class RelatorioService extends RestServiceBase {
  RelatorioService(RestConfig conf) : super(conf);

  String path = '/relatorios';

  Future<DataFrame<Cargo>> all(Filters filtros) async {
    final data = await getDataFrame<Cargo>(path,
        builder: Cargo.fromMap, filtros: filtros);

    return data;
  }
}
