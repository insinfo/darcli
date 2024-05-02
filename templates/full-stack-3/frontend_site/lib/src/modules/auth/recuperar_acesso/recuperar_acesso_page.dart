import 'dart:html' as html;
import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'recuperar-acesso-page',
  templateUrl: 'recuperar_acesso_page.html',
  styleUrls: ['recuperar_acesso_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    NavbarComponent,
  ],
  providers: [],
)
class RecuperarAcessoPage {
  final AuthService _authService;
  String login = '';
  bool isResetPass = false;

  RecuperarAcessoPage(this._authService, this._router);

  final Router _router;

  @ViewChild('page')
  html.DivElement? pageContainer;

  String email = '';

  Future<void> enviarNovaSenha() async {
    final loading = SimpleLoading();
    try {
      if (login.isEmpty) {
        SimpleDialogComponent.showAlert('CPF ou CNPJ tem que ser válido!');
        return;
      }
      login = login.replaceAll(RegExp(r'[^0-9]'), '');
      loading.show(target: pageContainer);
      var sol = await _authService.resetaSenha(login);
      email = sol.email;
      isResetPass = true;
    } catch (e, s) {
      print('RecuperarAcessoPage@enviarNovaSenha $e , $s');
      SimpleDialogComponent.showAlert('$e', subMessage: '$e $s');
    } finally {
      loading.hide();
    }
  }

  void irParaInicio() {
    _router.navigate(RoutePaths.login.toUrl());
  }
}
