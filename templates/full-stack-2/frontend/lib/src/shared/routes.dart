//REGISTRO DE ROTAS
import 'package:ngrouter/angular_router.dart';
import 'package:esic_frontend/src/shared/route_paths.dart';

//import 'package:notifis_frontend/src/modules/home/pages/home/home_page.template.dart'  as home_page;
import 'package:esic_frontend/src/modules/solicitante/pages/lista_solicitante/lista_solicitante.template.dart'
    as lista_solicitante_page;

import 'package:esic_frontend/src/modules/solicitante/pages/form_solicitante/form_solicitante.template.dart'
    as form_solicitante_page;

import 'package:esic_frontend/src/modules/solicitacao/pages/lista_solicitacao/lista_solicitacao.template.dart'
    as lista_solicitacao_page;

import 'package:esic_frontend/src/modules/solicitacao/pages/form_solicitacao/form_solicitacao.template.dart'
    as form_solicitacao_page;

class Routes {
  static final solicitante = RouteDefinition(
      routePath: RoutePaths.solicitante,
      component: lista_solicitante_page.ListaSolicitantePageNgFactory);

  static final solicitanteForm = RouteDefinition(
      routePath: RoutePaths.solicitanteForm,
      component: form_solicitante_page.FormSolicitantePageNgFactory);

  static final solicitacoes = RouteDefinition(
    routePath: RoutePaths.solicitacoes,
    component: lista_solicitacao_page.ListaSolicitacaoPageNgFactory,
    useAsDefault: true,
  );

  static final solicitacoesForm = RouteDefinition(
    routePath: RoutePaths.solicitacoesForm,
    component: form_solicitacao_page.FormSolicitacaoPageNgFactory,
  );

  static final all = <RouteDefinition>[
    solicitante,
    solicitanteForm,
    solicitacoes,
    solicitacoesForm

    /*RouteDefinition.redirect(
      path: 'home',
      redirectTo: RoutePaths.home.toUrl(),
    ),*/
  ];
}
