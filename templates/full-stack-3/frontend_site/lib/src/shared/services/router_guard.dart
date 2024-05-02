import 'dart:async';

import 'package:sibem_frontend_site/sibem_frontend_site.dart';
import 'package:sibem_frontend_site/src/modules/auth/cadastrar_usuario/cadastrar_usuario_page.dart';

import 'package:sibem_frontend_site/src/modules/auth/login/login_page.dart';
import 'package:sibem_frontend_site/src/modules/auth/recuperar_acesso/recuperar_acesso_page.dart';
import 'package:sibem_frontend_site/src/modules/home/pages/home_restrita/home_restrita_page.dart';
import 'package:sibem_frontend_site/src/modules/vaga/pages/lista_vaga/lista_vaga_page.dart';

class RouterGuard extends RouterHook {
  final AuthService _authService;
  final Injector _injector;

  late StreamSubscription onLogoutStreamSubscription;

  final _onNavigateStream = StreamController<RouterState>.broadcast();
  Stream<RouterState> get onNavigate => _onNavigateStream.stream;

  RouterGuard(this._authService, this._injector) {
    isLoggedIn();
    onLogoutStreamSubscription = _authService.onLogout.listen((event) {
      print('RouterGuard@onLogout');
      router.navigate(RoutePaths.login.toUrl());
    });
  }

  // Lazily inject `Router` to avoid cyclic dependency.
  Router? _router;
  Router get router => _router ??= _injector.provideType(Router);

  Future<void> isLoggedIn({bool updateOnLogout = true}) async {
    //print('verifica se esta logado');
    //check se o usuario esta logado
    await _authService.isLoggedIn(updateOnLogout: updateOnLogout);
  }

  @override
  Future<bool> canActivate(
      Object component, RouterState? oldState, RouterState newState) async {
    if (component is UnauthorizedPage) {
      return true;
    } else if (component is SessionExpiredPage) {
      return true;
    } else if (component is NotFoundPage) {
      return true;
    } else if (component is LoginPage) {
      return true;
    } else if (component is RecuperarAcessoPage) {
      return true;
    } else if (component is CadastrarUsuarioPage) {
      return true;
    } else if (component is ListaVagaPage) {
      await isLoggedIn(updateOnLogout: false);
      return true;
    } else if (component is HomeRestritaPage) {
      //so checa quando for acessar a HomeRestritaPage e não estiver vindo do login
      await isLoggedIn();
    }

    if (_authService.loginStatus == LoginStatus.notLogged) {
      router.navigate(RoutePaths.login.toUrl());
      return false;
    }

    return true;
  }
}
