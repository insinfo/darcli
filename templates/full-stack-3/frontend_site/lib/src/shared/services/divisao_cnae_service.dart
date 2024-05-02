import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class DivisaoCnaeService extends RestServiceBase {
  DivisaoCnaeService(RestConfig conf) : super(conf);

  String path = '/divisoes-cnae';

  Future<DataFrame<DivisaoCnae>> all(Filters filtros) async {
    final data = await getDataFrame<DivisaoCnae>(path,
        builder: DivisaoCnae.fromMap, filtros: filtros);

    return data;
  }

  Future<DivisaoCnae> getById(int id) async {
    return await getEntity<DivisaoCnae>('$path/$id',
        builder: DivisaoCnae.fromMap);
  }
}
