import 'package:sibem_backend/sibem_backend.dart';
import 'package:sibem_backend/src/shared/route_item.dart';

//registrar rotas aqui

const estatisticaPrivateRoutes = [
  MyRoute('get', '/estatisticas/encaminhados/mes-ano/:ano/:mes',
      EstatisticaController.totalEncaminhadosMesAno),
  MyRoute('get', '/estatisticas/empregadores/moderar/total',
      EstatisticaController.totalEmpregadorParaModerar),
  MyRoute('get', '/estatisticas/candidatos/moderar/total',
      EstatisticaController.totalCandidatosParaModerar),
  MyRoute('get', '/estatisticas/vagas/moderar/total',
      EstatisticaController.totalVagasParaModerar),
  MyRoute('get', '/estatisticas/vagas/total',
      EstatisticaController.totalVagasDisponiveis),
];
