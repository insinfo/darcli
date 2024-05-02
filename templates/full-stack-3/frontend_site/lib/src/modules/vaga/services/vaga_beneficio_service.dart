import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class VagaBeneficioService extends RestServiceBase {
  VagaBeneficioService(RestConfig conf) : super(conf);

  String path = '/beneficios';

  Future<DataFrame<Beneficio>> all(Filters filtros) async {
    final data =
        await getDataFrame<Beneficio>(path, builder: Beneficio.fromMap, filtros: filtros);
    return data;
  }

  // Future<Beneficio> getById(int id) async {
  //   return await getEntity<Beneficio>('$path/$id', builder: Beneficio.fromMap);
  // }

  // /// cadastra
  // Future<void> insert(Beneficio item) async {
  //   await insertEntity(item, path);
  // }

  // /// atualiza
  // Future<void> update(Beneficio item) async {
  //   await updateEntity(item, '$path/${item.id}');
  // }
}
