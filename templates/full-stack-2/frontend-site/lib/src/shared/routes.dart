//REGISTRO DE ROTAS
import 'package:ngrouter/angular_router.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';

import 'package:esic_frontend_site/src/modules/private/home/pages/bem_vindo/bem_vindo_page.template.dart'
    as bem_vindo_template;

import 'package:esic_frontend_site/src/modules/private/solicitacao/pages/cadastro_solicitacao/cadastro_solicitacao_page.template.dart'
    as cadastro_solicitacao_template;

import 'package:esic_frontend_site/src/modules/private/solicitacao/pages/lista_solicitacoes/lista_solicitacoes_page.template.dart'
    as lista_solicitacoes_template;

import 'package:esic_frontend_site/src/modules/private/solicitacao/pages/detalhe_solicitacao/detalhe_solicitacao_page.template.dart'
    as detalhe_solicitacao_template;
import 'package:esic_frontend_site/src/modules/private/home/pages/home_restrita/home_restrita_page.template.dart'
    as home_restrita_template;

import 'package:esic_frontend_site/src/modules/private/home/pages/alterar_senha/alterar_senha_page.template.dart'
    as alterar_senha_template;

// -------------------------- PUBLIC --------------------------

import 'package:esic_frontend_site/src/modules/public/home/pages/legislacao/legislacao_page.template.dart'
    as legislacao_template;

//import 'package:esic_frontend_site/src/modules/public/home/pages/home/home_page.template.dart' as home_page_template;

import 'package:esic_frontend_site/src/modules/public/home/pages/login/login_page.template.dart'
    as login_page_template;

import 'package:esic_frontend_site/src/modules/public/home/pages/cadastro_solicitante/cadastro_solicitante_page.template.dart'
    as cadastro_solicitante_template;

import 'package:esic_frontend_site/src/modules/public/home/pages/recuperar_acesso/recuperar_acesso_page.template.dart'
    as recuperar_acesso_template;

import 'package:esic_frontend_site/src/modules/public/estatistica/pages/estatistica_solicitacao/estatistica_solicitacao_page.template.dart'
    as estatistica_solicitacao_template;

class Routes {
  static final bemVindo = RouteDefinition(
    routePath: RoutePaths.bemVindo,
    component: bem_vindo_template.BemVindoPageNgFactory,
    useAsDefault: true,
  );

  static final criaSolicitacao = RouteDefinition(
    routePath: RoutePaths.criaSolicitacao,
    component: cadastro_solicitacao_template.CadastroSolicitacaoPageNgFactory,
  );

  static final listaSolicitacao = RouteDefinition(
    routePath: RoutePaths.listaSolicitacao,
    component: lista_solicitacoes_template.ListaSolicitacoesPageNgFactory,
  );

  static final detalheSolicitacao = RouteDefinition(
    routePath: RoutePaths.detalheSolicitacao,
    component: detalhe_solicitacao_template.DetalheSolicitacaoPageNgFactory,
  );

  static final alterarSenha = RouteDefinition(
    routePath: RoutePaths.alterarSenha,
    component: alterar_senha_template.AlterarSenhaPageNgFactory,
  );

  static final all = <RouteDefinition>[
    bemVindo,
    criaSolicitacao,
    listaSolicitacao,
    detalheSolicitacao,
    alterarSenha,
    /*RouteDefinition.redirect(
      path: 'home',
      redirectTo: RoutePaths.home.toUrl(),
    ),*/
  ];
}

class PublicRoutes {
  // static final home = RouteDefinition(
  //   routePath: RoutePaths.home,
  //   component: home_page_template.HomePageNgFactory,
  //   useAsDefault: true,
  // );
  static final restrito = RouteDefinition(
    routePath: RoutePaths.restrito,
    component: home_restrita_template.HomeRestritaPageNgFactory,
  );

  static final login = RouteDefinition(
    routePath: RoutePaths.login,
    component: login_page_template.LoginPageNgFactory,
    useAsDefault: true,
  );

  static final cadastroSolicitante = RouteDefinition(
    routePath: RoutePaths.cadastroSolicitante,
    component: cadastro_solicitante_template.CadastroSolicitantePageNgFactory,
  );

  static final legislacao = RouteDefinition(
    routePath: RoutePaths.legislacao,
    component: legislacao_template.LegislacaoPageNgFactory,
  );

  static final recuperarAcesso = RouteDefinition(
    routePath: RoutePaths.recuperarAcesso,
    component: recuperar_acesso_template.RecuperarAcessoPageNgFactory,
  );

  static final estatisticaSolicitacao = RouteDefinition(
    routePath: RoutePaths.estatisticaSolicitacao,
    component:
        estatistica_solicitacao_template.EstatisticaSolicitacaoPageNgFactory,
  );

  static final all = <RouteDefinition>[
    login,
    legislacao,
    cadastroSolicitante,
    recuperarAcesso,
    restrito,
    estatisticaSolicitacao,
  ];
}
