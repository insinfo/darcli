
/*import 'package:sibem_frontend/sibem_frontend.dart';


class RouterGuard extends RouterHook {
  final AuthService _authService;
  final Injector _injector;
  SimpleLoading _simpleLoading;
  StreamSubscription onLogoutStreamSubscription;

  StreamController<RouterState> _onNavigateStream = StreamController<RouterState>.broadcast();
  Stream<RouterState> get onNavigate => _onNavigateStream.stream;

  RouterGuard(this._authService, this._injector) {
    _simpleLoading = SimpleLoading();
  }

  // Lazily inject `Router` to avoid cyclic dependency.
  Router _router;
  Router get router => _router ??= _injector.provideType(Router);

  var _isLogged = false;

  Future<void> isLoggedIn() async {
    _simpleLoading.show();
    //check se o usuario esta logado e com permissão
    _isLogged = await _authService.isLoggedIn();
    _simpleLoading.hide();
  }

  @override
  Future<bool> canActivate(Object component, RouterState oldState, RouterState newState) async {
    //print('RouterGuard@canActivate $_isLogged | $component | ${oldState?.routePath.path} | ${newState.routePath.path}');

    await isLoggedIn();
    print('router_guard@ ${newState?.routePath?.path}');
    //so checa quando for acessar a MainPage e não estiver vindo do login
    //  await isLoggedIn();

    // se for passTrue autoriza acesso sem checar permissão

    if (_isLogged == false) {
      //! criar pagina de acesso não autorizado/logado
      //router.navigate(RoutePaths.unauthorizedPrivate.toUrl());
    }

    ///exemplo de como redirecionar um usuario para uma pagina especifica
    // var isAdmin = _authService.isAdmin();
    // print('RouterGuard@isAdmin: $isAdmin');
    // if (isAdmin) {
    //   router.navigate(RoutePaths.encaminhamento.toUrl());
    // }

    return true;
  }
}
*/