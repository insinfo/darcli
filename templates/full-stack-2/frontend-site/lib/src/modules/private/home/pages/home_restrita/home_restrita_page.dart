import 'dart:async';

import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:esic_frontend_site/src/shared/routes.dart';
import 'package:esic_frontend_site/src/shared/services/auth_service.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
  selector: 'home-restrita-page',
  templateUrl: 'home_restrita_page.html',
  styleUrls: ['home_restrita_page.css'],
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [
    Routes,
    RoutePaths,
  ],
  providers: [],
)
class HomeRestritaPage implements OnInit, OnDestroy, CanActivate {
  LoginStatus loginStatus = LoginStatus.checking;
  SimpleLoading loading = SimpleLoading();

  final AuthService authService;
  final Router _router;

  late StreamSubscription onLogoutStreamSubscription;
  late StreamSubscription onCheckPermissionStreamSubscription;

  HomeRestritaPage(this.authService, this._router) {
    /*authService.onLogin.listen((event) {
      loginStatus = event;
      print('onLogin');
    });*/
    onLogoutStreamSubscription = authService.onLogout.listen((event) {
      loginStatus = event;
      //print('HomeRestritaPage@onLogout');
      _router.navigate(RoutePaths.login.toUrl());
    });
    onCheckPermissionStreamSubscription =
        authService.onCheckPermission.listen((event) {
      loginStatus = event;
      if (loginStatus != LoginStatus.logged) {
        _router.navigate(RoutePaths.login.toUrl());
      }
      // print('HomeRestritaPage@onCheckPermission $event');
    });
  }
  @override
  Future<bool> canActivate(RouterState? current, RouterState next) {
    loading.showHorizontal2();
    final isLogged = authService.checkPermissionServer();
    loading.hide();
    return isLogged;
  }

  @override
  void ngOnInit() async {
    //
    // await authService.checkPermissionServer();
    // loading.hide();
  }

  @override
  void ngOnDestroy() async {
    // print('HomeRestritaPage ngOnDestroy');
    await onLogoutStreamSubscription.cancel();
    await onCheckPermissionStreamSubscription.cancel();
  }
}
