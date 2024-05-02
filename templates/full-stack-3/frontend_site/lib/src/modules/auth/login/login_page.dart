import 'dart:html' as html;

import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'login-page',
  templateUrl: 'login_page.html',
  styleUrls: ['login_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    routerDirectives,
    FooterComponent,
    NavbarComponent,
  ],
  exports: [RoutePaths],
)
class LoginPage implements CanActivate, OnInit, OnActivate, AfterViewInit {
  final Router _router;
  @ViewChild('page')
  html.DivElement? pageContainer;
  final AuthService authService;

  final loginPayload = LoginPayload(login: '', password: '');

  LoginPage(this.authService, this._router);

  @override
  Future<bool> canActivate(RouterState? current, RouterState next) async {
    return true;
  }

  @override
  void ngOnInit() {}

  bool validateForm() {
    if (loginPayload.login.trim() == '') {
      SimpleDialogComponent.showAlert('O nome de usuário não pode estar vazio!',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }
    if (loginPayload.password.trim() == '') {
      SimpleDialogComponent.showAlert('A senha não pode estar vazia!',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }
    return true;
  }

  void doLogin() async {
    if (!validateForm()) {
      return;
    }
    final loading = SimpleLoading();
    try {
      loading.show(target: pageContainer);
      loginPayload.login = loginPayload.login.replaceAll(RegExp(r'[^0-9]'), '');
      await authService.doLogin(loginPayload);

      _router.navigate(RoutePaths.restrito.toUrl());
    } catch (e, s) {
      print('LoginPage@doLogin $e $s');
      SimpleDialogComponent.showAlert(
          'Não foi possível autenticar, verifique seu nome de usuário ou senha. Este usuário pode ainda não estar registrado ou ativado!',
          subMessage: '$e');
    } finally {
      loading.hide();
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) {}

  @override
  void ngAfterViewInit() {}
}
