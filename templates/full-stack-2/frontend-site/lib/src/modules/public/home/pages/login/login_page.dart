import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:esic_frontend_site/src/shared/services/auth_service.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';
import 'package:ngrouter/ngrouter.dart';
import 'dart:html' as html;

@Component(
  selector: 'login-page',
  templateUrl: 'login_page.html',
  styleUrls: ['login_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  providers: [],
)
class LoginPage implements OnInit {
  final AuthService authService;

  SimpleLoading loading = SimpleLoading();
  LoginPayload loginPayload = LoginPayload(login: '', password: '');
  final Router _router;

  @ViewChild('page')
  html.DivElement? pageContainer;

  LoginPage(
    this.authService,
    this._router,
  );

  @override
  void ngOnInit() {
    //
  }

  void doLogin() async {
    try {
      loading.show(target: pageContainer);
      loginPayload.login = loginPayload.login.replaceAll(RegExp(r'[^0-9]'), '');
      await authService.doLogin(loginPayload);
      await _router.navigate(RoutePaths.restrito.toUrl());
    } on UserNotActivatedException {
      SimpleDialogComponent.showAlert(
          'Usuário não ativado, acesse seu email para ativar o cadastro!');
    } catch (e, s) {
      print('LoginPage@doLogin $e , $s');
      SimpleDialogComponent.showAlert(
          'Não foi possível autenticar, verifique seu nome de usuário ou senha.',
          subMessage: '$e $s');
    } finally {
      loading.hide();
    }
  }

  void irParaCadastro() {
    _router.navigate(
        RoutePaths.cadastroSolicitante.toUrl(parameters: {'id': 'new'}));
  }

  void irParaRecuperarAcesso() {
    _router.navigate(RoutePaths.recuperarAcesso.toUrl());
  }
}
