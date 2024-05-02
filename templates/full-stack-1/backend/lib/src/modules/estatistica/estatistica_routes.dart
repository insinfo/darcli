import 'package:new_sali_backend/src/shared/utils/route_item.dart';
import 'package:new_sali_backend/new_sali_backend.dart';

//registrar rotas do modulo estatistica aqui
const estatisticaPrivatesRoutes = [
  RouteItem('get', '/estatistica/processos/ano',
      EstatisticaController.totalProcessosPorAno),
  RouteItem('get', '/estatistica/processos/periodo/setor/primero/tramite',
      EstatisticaController.processByPeriodoSetorPrimeroTramite),
  RouteItem('get', '/estatistica/processos/situacao',
      EstatisticaController.processosPorSituacao),
  RouteItem('get', '/estatistica/processos/classificacao',
      EstatisticaController.totalProcessosPorClassificacao),
  RouteItem('get', '/estatistica/processos/assunto',
      EstatisticaController.totalProcessosPorAssunto),
];
