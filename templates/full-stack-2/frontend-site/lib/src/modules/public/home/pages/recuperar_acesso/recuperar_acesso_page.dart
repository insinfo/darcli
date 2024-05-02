import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:esic_frontend_site/src/shared/services/auth_service.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';
import 'dart:html' as html;

import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'recuperar-acesso-page',
  templateUrl: 'recuperar_acesso_page.html',
  styleUrls: ['recuperar_acesso_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  providers: [],
)
class RecuperarAcessoPage {
  final AuthService _authService;
  String cpfOrCnpj = '';
  bool isResetPass = false;

  RecuperarAcessoPage(this._authService, this._router);

  SimpleLoading loading = SimpleLoading();
  final Router _router;

  @ViewChild('page')
  html.DivElement? pageContainer;

  String email = '';

  Future<void> enviarNovaSenha() async {
    try {
      if (cpfOrCnpj.isEmpty) {
        SimpleDialogComponent.showAlert(' CPF ou CNPJ tem que ser válido!');
        return;
      }
      cpfOrCnpj = cpfOrCnpj.replaceAll(RegExp(r'[^0-9]'), '');
      loading.show(target: pageContainer);
      var sol = await _authService.resetaSenha(cpfOrCnpj);
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
