import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';

class OrganogramaService extends RestServiceBase {
  OrganogramaService(RestConfig conf) : super(conf);

  String path = '/administracao/organograma';

  /// tras a arove de organograma do backend 
  /// lista a hierarquia de Organograma como um arvore
  Future<DataFrame<Organograma>> getHierarquia(Filters filtros,
      {bool removeDisabled = false}) async {
    final data = await getDataFrame<Organograma>('$path/hierarquia',
        builder: (x) => Organograma.fromMap(x), filtros: filtros);

    // if (removeDisabled) {
    //   data.removeWhere((o) => o.nomOrgao.toLowerCase().trim().startsWith('x'));
    // }

    return data;
  }
}
