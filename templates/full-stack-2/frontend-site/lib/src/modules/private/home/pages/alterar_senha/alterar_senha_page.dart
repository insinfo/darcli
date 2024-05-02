import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:esic_frontend_site/src/shared/services/auth_service.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';
import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'alterar-senha-page',
  templateUrl: 'alterar_senha_page.html',
  styleUrls: ['alterar_senha_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  providers: [],
)
class AlterarSenhaPage {
  final AuthService _authService;
  final SimpleLoading _simpleLoading = SimpleLoading();
  String cpfOrCnpj = '';
  String senhaAtual = '';
  String novaAtual = '';
  bool isResetPass = false;
  final Router _router;

  AlterarSenhaPage(this._authService, this._router);

  Future<void> trocaSenha() async {
    try {
      if (novaAtual.length < 6) {
        SimpleDialogComponent.showAlert(
            'A senha não pode estar vazia e deve ter pelo menos 6 caracteres!');
        return;
      }
      _simpleLoading.show();
      await _authService.trocaSenha(cpfOrCnpj, senhaAtual, novaAtual);
      isResetPass = true;
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao trocar a senha, $e',
          subMessage: '$e $s');
    } finally {
      _simpleLoading.hide();
    }
  }

  void irParaInicio() {
    _router.navigate(RoutePaths.bemVindo.toUrl());
  }
}
