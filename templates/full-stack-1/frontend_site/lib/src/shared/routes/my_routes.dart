import 'package:new_sali_frontend_site/src/shared/routes/route_paths.dart';


import 'package:new_sali_frontend_site/src/modules/protocolo/pages/consulta_processo/consulta_processo_page.template.dart'
    as consulta_processo_template;

import 'package:new_sali_frontend_site/src/modules/protocolo/pages/visualizar_processo/visualizar_processo_page.template.dart'
    as visualiza_processo_template;
import 'package:ngdart/angular.dart';

class MyRoutes {
  // public
  static final consultaProcesso = RouteDefinition(
    routePath: RoutePaths.consultaProcesso,
    component: consulta_processo_template.ConsultaProcessoPageNgFactory,
    useAsDefault: true,
  );

  static final visualizaProcesso = RouteDefinition(
    routePath: RoutePaths.visualizaProcesso,
    component: visualiza_processo_template.VisualizaProcessoPageNgFactory,
  );

  static final allPublic = <RouteDefinition>[
    consultaProcesso,
    visualizaProcesso,
  ];
}
