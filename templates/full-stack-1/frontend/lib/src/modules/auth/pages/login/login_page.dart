import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/modules/home/services/acao_favorita_service.dart';
import 'package:new_sali_frontend/src/shared/components/loading/loading.dart';
import 'package:new_sali_frontend/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:new_sali_frontend/src/shared/routes/route_paths.dart';
import 'package:new_sali_frontend/src/shared/services/auth_service.dart';
import 'package:ngdart/angular.dart';


import 'dart:html' as html;



@Component(
  selector: 'login-page',
  templateUrl: 'login_page.html',
  styleUrls: ['login_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  exports: [],
)
class LoginPage implements OnInit {
  final Router _router;
  @ViewChild('page')
  html.DivElement? pageContainer;
  final AuthService authService;
  final AcaoFavoritaService _acaoFavoritaService;

  SimpleLoading loading = SimpleLoading();
  LoginPayload loginPayload = LoginPayload(
    username: '',
    password: '',
    anoExercicio: DateTime.now().year.toString(),
  );

  LoginPage(this.authService, this._router, this._acaoFavoritaService);

  @override
  void ngOnInit() {
    //
  }

  bool validateForm() {
    if (loginPayload.username.trim() == '') {
      SimpleDialogComponent.showAlert('O nome de usuário não pode esta vazio!',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }
    if (loginPayload.password.trim() == '') {
      SimpleDialogComponent.showAlert('A senha não pode esta vazia!',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }

    if (loginPayload.anoExercicioAsInt == null) {
      SimpleDialogComponent.showAlert('O ExercÍcio não pode esta vazio!',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }
    return true;
  }

  void doLogin() async {
    if (!validateForm()) {
      return;
    }
    try {
      loading.show(target: pageContainer);
      //loginPayload.username = loginPayload.username.replaceAll(RegExp(r'[^0-9]'), '');
      await authService.doLogin(loginPayload);
      // apos o login diz que não carregou os favoritos para que a componente Favoritos
      // seja forçado a carregar os favoritos apos o login
      _acaoFavoritaService.isLoadFavoritos = false;
      _router.navigate(RoutePaths.restrito.toUrl());
    } catch (e, s) {
      print('LoginPage@doLogin $e $s');
      SimpleDialogComponent.showAlert(
          'Não foi possível autenticar, verifique seu nome de usuário ou senha.',
          subMessage: '$e');
    } finally {
      loading.hide();
    }
  }
}
