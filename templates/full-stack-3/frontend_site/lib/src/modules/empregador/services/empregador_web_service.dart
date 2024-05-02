import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class EmpregadorWebService extends RestServiceBase {
  EmpregadorWebService(RestConfig conf) : super(conf);

  String path = '/empregadores-web';

  Future<DataFrame<EmpregadorWeb>> all(Filters filtros) async {
    final data = await getDataFrame<EmpregadorWeb>(path,
        builder: EmpregadorWeb.fromMap, filtros: filtros);
    return data;
  }

  Future<EmpregadorWeb> getById(int id) async {
    return await getEntity<EmpregadorWeb>('$path/$id',
        builder: EmpregadorWeb.fromMap);
  }

  Future<EmpregadorWeb> getByCpfOrCnpj(String cpfOrCnpj) async {
    cpfOrCnpj = cpfOrCnpj.replaceAll(RegExp(r'[^0-9]'), '');
    return await getEntity<EmpregadorWeb>('$path/cpfOrCnpj/$cpfOrCnpj',
        builder: EmpregadorWeb.fromMap);
  }

  /// cadastra
  Future<void> insert(EmpregadorWeb item) async {
    await insertEntity(item, path);
  }

  /// atualiza
  Future<void> update(EmpregadorWeb item) async {
    await updateEntity(item, '$path/${item.id}');
  }
}
