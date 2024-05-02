import 'package:esic_frontend_site/src/shared/services/auth_service.dart';
import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:esic_frontend_site/src/shared/routes.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
  selector: 'header-component',
  styleUrls: ['header.css'],
  templateUrl: 'header.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [Routes, RoutePaths, LoginStatus],
)
class HeaderComponent {
  final AuthService authService;
  final Router _router;
  SimpleLoading loading = SimpleLoading();
  HeaderComponent(this.authService, this._router);

  bool showMenu = true;

  void doLogout() {
    //loading.show();
    authService.doLogout();
    _router.navigate(RoutePaths.login.toUrl());
    //loading.hide();
  }

  void irParaCadastro() {
    _router.navigate(
        RoutePaths.cadastroSolicitante.toUrl(parameters: {'id': 'new'}));
  }

  void navbarToggle() {
    showMenu = !showMenu;
  }
}
