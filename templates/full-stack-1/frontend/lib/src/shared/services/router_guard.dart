import 'dart:async';
import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:new_sali_frontend/src/modules/auth/pages/login/login_page.dart';
import 'package:new_sali_frontend/src/modules/home/pages/home/home_page.dart';
import 'package:new_sali_frontend/src/modules/home/pages/main_page/main_page.dart';
import 'package:new_sali_frontend/src/shared/components/not_found/not_found_page.dart';
import 'package:new_sali_frontend/src/shared/components/session_expired_page/session_expired_page.dart';
import 'package:new_sali_frontend/src/shared/components/unauthorized/unauthorized_page.dart';


import 'dart:html' as html;

class RouterGuard extends RouterHook {
  final AuthService _authService;
  final Injector _injector;
  late SimpleLoading _simpleLoading;
  late StreamSubscription onLogoutStreamSubscription;

  StreamController<RouterState> _onNavigateStream =
      StreamController<RouterState>.broadcast();
  Stream<RouterState> get onNavigate => _onNavigateStream.stream;

  RouterGuard(this._authService, this._injector) {
    _simpleLoading = SimpleLoading();

    onLogoutStreamSubscription = _authService.onLogout.listen((event) {
      print('RouterGuard@onLogout');
      router.navigate(RoutePaths.login.toUrl());
    });
  }

  // Lazily inject `Router` to avoid cyclic dependency.
  Router? _router;
  Router get router => _router ??= _injector.provideType(Router);

  var _isLogged = false;

  Future<void> isLoggedIn() async {
    _simpleLoading.showHorizontal2(
        target: html.document.querySelector('.content-wrapper'));
    //check se o usuario esta logado e com permissão
    _isLogged = await _authService.isLoggedIn();
    _simpleLoading.hide();
  }

  var _temPermissao = false;

  Future<void> checkPermissao(int? codAcao, int? codFuncionalidade,
      int? codModulo, int? codGestao) async {
    _simpleLoading.showHorizontal2(
        target: html.document.querySelector('.content-wrapper'));
    _temPermissao = await _authService.checkPermissao(
        codAcao, codFuncionalidade, codModulo, codGestao);
    _simpleLoading.hide();
  }

  @override
  Future<bool> canActivate(
      Object component, RouterState? oldState, RouterState newState) async {
    //print('RouterGuard@canActivate $_isLogged | $component | ${oldState?.routePath.path} | ${newState.routePath.path}');
    if (!(component is MainPage)) {
      _onNavigateStream.add(newState);
    }

    if (component is SobrePage) {
      return true;
    } else if (component is UnauthorizedPage) {
      return true;
    } else if (component is SessionExpiredPage) {
      return true;
    } else if (component is NotFoundPage) {
      return true;
    } else if (component is LoginPage) {
      return true;
    } else if (component is HomePage) {
      return true;
    } else if (component is MainPage) {
      //so checa quando for acessar a MainPage e não estiver vindo do login
      await isLoggedIn();
    } else {
      //se for outra rota qualquer verifica se tem permissão
      var passTrue = newState.queryParameters['pt'];
      // se for passTrue autoriza acesso sem checar permissão
      if (passTrue != 'true') {
        var codAcao = int.tryParse(newState.queryParameters['a'].toString());
        var codFuncionalidade =
            int.tryParse(newState.queryParameters['f'].toString());
        var codModulo = int.tryParse(newState.queryParameters['m'].toString());
        var codGestao = int.tryParse(newState.queryParameters['g'].toString());
        await checkPermissao(codAcao, codFuncionalidade, codModulo, codGestao);
        // print(  'RouterGuard component $component $_temPermissao ${newState.queryParameters}');
        if (_temPermissao == false) {
          router.navigate(RoutePaths.unauthorizedPrivate.toUrl());
        }
      }
    }

    if (_isLogged == false) {
      //print('RouterGuard@canActivate não autorizado');
      router.navigate(RoutePaths.login.toUrl());
      return false;
    }

    return true;
  }
}
