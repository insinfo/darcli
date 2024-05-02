import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'bem-vindo-page',
  styleUrls: ['bem_vindo_page.css'],
  templateUrl: 'bem_vindo_page.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [Routes, RoutePaths, CandidatoStatus],
)
class BemVindoPage {
  final AuthService authService;
  // ignore: unused_field
  final Router _router;
  BemVindoPage(this.authService, this._router) {
    //
  }

  void irParaCadastroCandidato() async {
    if (this.authService.authPayload.jaCadastrado == true) {
      SimpleDialogComponent.showAlert('Você já fez seu cadastro!');
      return;
    }
    _router.navigate(RoutePaths.formCandidatoWeb.toUrl());
  }

  void irParaCadastroEmpregador() async {
    if (this.authService.authPayload.jaCadastrado == true) {
      //SimpleDialogComponent.showAlert('Você já fez seu cadastro!');
      _router.navigate(RoutePaths.formVaga.toUrl(parameters: {'id': 'new'}));
      return;
    }
    _router.navigate(RoutePaths.formEmpregadorWeb.toUrl());
  }
}
