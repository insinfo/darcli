import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:new_sali_frontend/src/modules/auth/pages/login/login_page.template.dart'
    as login_template;

import 'package:new_sali_frontend/src/modules/home/pages/main_page/main_page.template.dart'
    as main_page_template;

import 'package:new_sali_frontend/src/modules/home/pages/home/home_page.template.dart'
    as home_page_template;

import 'package:new_sali_frontend/src/modules/home/pages/sobre/sobre_page.template.dart'
    as sobre_page_template;

import 'package:new_sali_frontend/src/shared/components/not_found/not_found_page.template.dart'
    as not_found_template;

import 'package:new_sali_frontend/src/shared/components/unauthorized/unauthorized_page.template.dart'
    as unauthorized_template;

import 'package:new_sali_frontend/src/modules/auth/pages/alterar_senha/alterar_senha_page.template.dart'
    as alterar_senha_template;

import 'package:new_sali_frontend/src/shared/components/not_implemented/not_implemented_page.template.dart'
    as not_implemented_template;

import 'package:new_sali_frontend/src/shared/components/session_expired_page/session_expired_page.template.dart'
    as session_expired_page_template;

class MyRoutes {
  // public

  static final sobre = RouteDefinition(
    routePath: RoutePaths.sobre,
    component: sobre_page_template.SobrePageNgFactory,
  );

  static final login = RouteDefinition(
    routePath: RoutePaths.login,
    component: login_template.LoginPageNgFactory,
  );

  static final sessionExpired = RouteDefinition(
    routePath: RoutePaths.sessionExpired,
    component: session_expired_page_template.SessionExpiredPageNgFactory,
  );

  static final alterarSenha = RouteDefinition(
    routePath: RoutePaths.alterarSenha,
    component: alterar_senha_template.AlterarSenhaPageNgFactory,
  );

  static final restrito = RouteDefinition(
    routePath: RoutePaths.restrito,
    component: main_page_template.MainPageNgFactory,
    useAsDefault: true,
  );

  // private
  static final home = RouteDefinition(
    routePath: RoutePaths.home,
    component: home_page_template.HomePageNgFactory,
    useAsDefault: true,
  );

  static final notFound = RouteDefinition(
    path: '.+',
    component: not_found_template.NotFoundPageNgFactory,
  );

  static final notFoundPrivate = RouteDefinition(
    routePath: RoutePaths.notFoundPrivate,
    component: not_found_template.NotFoundPageNgFactory,
  );

  static final unauthorized = RouteDefinition(
    routePath: RoutePaths.unauthorized,
    component: unauthorized_template.UnauthorizedPageNgFactory,
  );

  static final unauthorizedPrivate = RouteDefinition(
    routePath: RoutePaths.unauthorizedPrivate,
    component: unauthorized_template.UnauthorizedPageNgFactory,
  );

  static final notImplemented = RouteDefinition(
    routePath: RoutePaths.notImplemented,
    component: not_implemented_template.NotImplementedPageNgFactory,
  );

  static final allPrivate = <RouteDefinition>[
    home,
    alterarSenha,

    //notFound,
    unauthorizedPrivate,
    notFoundPrivate,
    notImplemented,
    sobre,
  ];

  static final allPublic = <RouteDefinition>[
    login,
    sessionExpired,
    restrito,
    unauthorized,
    notFound,
  ];
}
