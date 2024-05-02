import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class CandidatoService extends RestServiceBase {
  CandidatoService(RestConfig conf) : super(conf);

  String path = '/candidatos';

  Future<DataFrame<Candidato>> getAllByEmpregador(
      int idEmpregador, Filters filtros) async {
    final data = await getDataFrame<Candidato>('$path/empregador/$idEmpregador',
        builder: Candidato.fromMap, filtros: filtros);
    return data;
  }

  Future<Candidato> getById(int id) async {
    return await getEntity<Candidato>('$path/$id', builder: Candidato.fromMap);
  }
}
