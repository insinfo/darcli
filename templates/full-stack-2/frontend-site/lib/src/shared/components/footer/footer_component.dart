import 'package:esic_frontend_site/src/shared/services/auth_service.dart';
import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:esic_frontend_site/src/shared/routes.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
  selector: 'footer-component',
  styleUrls: ['footer_component.css'],
  templateUrl: 'footer_component.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [Routes, RoutePaths, LoginStatus],
)
class FooterComponent {
  final AuthService authService;
  final Router _router;
  SimpleLoading loading = SimpleLoading();
  FooterComponent(this.authService, this._router);

  void irParaCadastro() {
    _router.navigate(
        RoutePaths.cadastroSolicitante.toUrl(parameters: {'id': 'new'}));
  }
}
