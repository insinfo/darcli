import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class TipoDeficienciaService extends RestServiceBase {
  TipoDeficienciaService(RestConfig conf) : super(conf);

  String path = '/tipos-deficiencia';

  Future<DataFrame<TipoDeficiencia>> all(Filters filtros) async {
    final data = await getDataFrame<TipoDeficiencia>(path,
        builder: TipoDeficiencia.fromMap, filtros: filtros);

    return data;
  }

  Future<TipoDeficiencia> getById(int id) async {
    return await getEntity<TipoDeficiencia>('$path/$id',
        builder: TipoDeficiencia.fromMap);
  }
}
