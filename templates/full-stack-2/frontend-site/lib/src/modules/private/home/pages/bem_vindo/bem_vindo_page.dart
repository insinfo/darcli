import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:esic_frontend_site/src/shared/routes.dart';
import 'package:esic_frontend_site/src/shared/services/auth_service.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';

@Component(
  selector: 'bem-vindo-page',
  styleUrls: ['bem_vindo_page.css'],
  templateUrl: 'bem_vindo_page.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [
    Routes,
    RoutePaths,
  ],
)
class BemVindoPage {
  final AuthService authService;
  final Router _router;
  BemVindoPage(this.authService, this._router) {
    //
  }

  void irParaCadastro() async {
    //'/#/cadastro-solicitante/${authService.idPessoa}'
    // await _router.navigate(RoutePaths.cadastroSolicitante.toUrl(parameters: {
    //   'id': authService.idPessoa.toString(),
    // }));
    await _router.navigate(RoutePaths.cadastroSolicitante.toUrl(parameters: {
      'id': 'atual',
    }));
  }
}
