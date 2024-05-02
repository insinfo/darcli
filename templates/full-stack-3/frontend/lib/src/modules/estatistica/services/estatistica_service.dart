import 'package:sibem_frontend/sibem_frontend.dart';

class EstatisticaService extends RestServiceBase {
  EstatisticaService(RestConfig conf) : super(conf);

  String path = '/estatisticas';

  /// lista o total de Encaminhados por mes/ano
  Future<List<Map<String, dynamic>>> totalEncaminhadosMesAno(
      {int? ano, int? mes}) async {
    return await getListMap('$path/encaminhados/mes-ano/$ano/$mes');
  }

  Future<Map<String, dynamic>> totalEmpregadorParaModerar() async {
    return await getJson('$path/empregadores/moderar/total');
  }

  Future<Map<String, dynamic>> totalCandidatosParaModerar() async {
    return await getJson('$path/candidatos/moderar/total');
  }

  Future<Map<String, dynamic>> totalVagasParaModerar() async {
    return await getJson('$path/vagas/moderar/total');
  }

  Future<Map<String, dynamic>> totalVagasDisponiveis() async {
    return await getJson('$path/vagas/total');
  }
}
