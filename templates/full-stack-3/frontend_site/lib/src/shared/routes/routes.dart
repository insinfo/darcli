import 'package:sibem_frontend_site/sibem_frontend_site.dart';

export 'route_paths.dart';

import 'package:sibem_frontend_site/src/shared/components/session_expired_page/session_expired_page.template.dart'
    as session_expired_page_template;

import 'package:sibem_frontend_site/src/modules/auth/login/login_page.template.dart'
    as login_template;
import 'package:sibem_frontend_site/src/modules/auth/cadastrar_usuario/cadastrar_usuario_page.template.dart'
    as cadastrar_usuario_template;
import 'package:sibem_frontend_site/src/modules/home/pages/home_restrita/home_restrita_page.template.dart'
    as home_restrita_template;
import 'package:sibem_frontend_site/src/modules/home/pages/bem_vindo/bem_vindo_page.template.dart'
    as bem_vindo_template;
import 'package:sibem_frontend_site/src/modules/auth/recuperar_acesso/recuperar_acesso_page.template.dart'
    as recuperar_acesso_template;
import 'package:sibem_frontend_site/src/modules/vaga/pages/lista_vaga/lista_vaga_page.template.dart'
    as lista_vaga_template;
import 'package:sibem_frontend_site/src/modules/candidato/pages/form_candidato/form_candidato_web_page.template.dart'
    as form_candidato_template;

import 'package:sibem_frontend_site/src/modules/empregador/pages/form_enpregador/form_enpregador_web_page.template.dart'
    as form_empregadorWeb_template;
import 'package:sibem_frontend_site/src/modules/vaga/pages/form_vaga/form_vaga_page.template.dart'
    as form_vaga_template;
import 'package:sibem_frontend_site/src/modules/auth/alterar_senha/alterar_senha_page.template.dart'
    as alterar_senha_template;

import 'package:sibem_frontend_site/src/modules/candidato/pages/lista_candidato/lista_candidato_page.template.dart'
    as lista_candidato_template;

class Routes {
  // public
  static final login = RouteDefinition(
    routePath: RoutePaths.login,
    component: login_template.LoginPageNgFactory,
  );
  static final recuperarAcesso = RouteDefinition(
    routePath: RoutePaths.recuperarAcesso,
    component: recuperar_acesso_template.RecuperarAcessoPageNgFactory,
  );
  static final cadastrarUsuario = RouteDefinition(
    routePath: RoutePaths.cadastrarUsuario,
    component: cadastrar_usuario_template.CadastrarUsuarioPageNgFactory,
  );
  static final restrito = RouteDefinition(
    routePath: RoutePaths.restrito,
    component: home_restrita_template.HomeRestritaPageNgFactory,
    useAsDefault: true,
  );
  static final listaVaga = RouteDefinition(
    routePath: RoutePaths.listaVaga,
    component: lista_vaga_template.ListaVagaPageNgFactory,
  );

  //privates
  static final bemVindo = RouteDefinition(
    routePath: RoutePaths.bemVindo,
    component: bem_vindo_template.BemVindoPageNgFactory,
    useAsDefault: true,
  );
  static final formCandidatoWeb = RouteDefinition(
    routePath: RoutePaths.formCandidatoWeb,
    component: form_candidato_template.FormCandidatoWebPageNgFactory,
  );

  static final formEmpregadorWeb = RouteDefinition(
    routePath: RoutePaths.formEmpregadorWeb,
    component: form_empregadorWeb_template.FormEnpregadorWebPageNgFactory,
  );
  static final formVaga = RouteDefinition(
    routePath: RoutePaths.formVaga,
    component: form_vaga_template.FormVagaPageNgFactory,
  );
  static final alterarSenha = RouteDefinition(
    routePath: RoutePaths.alterarSenha,
    component: alterar_senha_template.AlterarSenhaPageNgFactory,
  );

  static final sessionExpired = RouteDefinition(
    routePath: RoutePaths.sessionExpired,
    component: session_expired_page_template.SessionExpiredPageNgFactory,
  );

  static final listaCandidatoEncaminhado = RouteDefinition(
    routePath: RoutePaths.listaCandidatoEncaminhado,
    component: lista_candidato_template.ListaCandidatoEncaminhadoPageNgFactory,
  );

  static final allPrivate = <RouteDefinition>[
    sessionExpired,
    bemVindo,
    formCandidatoWeb,
    formEmpregadorWeb,
    formVaga,
    alterarSenha,
    listaCandidatoEncaminhado,
  ];

  static final allPublic = <RouteDefinition>[
    login,
    cadastrarUsuario,
    sessionExpired,
    restrito,
    recuperarAcesso,
    listaVaga,
  ];
}
