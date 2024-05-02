import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/components/loading/loading.dart';
import 'package:new_sali_frontend/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:new_sali_frontend/src/shared/services/auth_service.dart';
import 'package:ngdart/angular.dart';


@Component(
  selector: 'alterar-senha-page',
  templateUrl: 'alterar_senha_page.html',
  styleUrls: ['alterar_senha_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  exports: [],
)
class AlterarSenhaPage implements OnActivate {
  final Router router;
  AuthService _authService;
  String username = '';
  String senhaAtual = '';
  String novaSenha = '';
  String confirmacaoSenha = '';
  SimpleLoading _simpleLoading = SimpleLoading();
  AlterarSenhaPage(this.router, this._authService) {}

  bool validateForm() {
    if (username.trim() == '') {
      SimpleDialogComponent.showAlert('A username não pode estar vazio!',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }
    
    if (isAdmin == false) {
      if (senhaAtual.trim() == '') {
        SimpleDialogComponent.showAlert('A senha atual não pode estar vazia!',
            subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
        return false;
      }
    }

    if (novaSenha.trim() == '') {
      SimpleDialogComponent.showAlert('A nova senha não pode estar vazia!',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }

    if (novaSenha != confirmacaoSenha) {
      SimpleDialogComponent.showAlert(
          'A "Nova Senha" tem que ser igual a "Confirmação Senha"! $novaSenha $confirmacaoSenha ',
          subMessage: 'Campos tem que ser iguais!',
          dialogColor: DialogColor.DANGER);
      return false;
    }

    if (isAdmin == false) {
      if (username.trim().toLowerCase() !=
          _authService.authPayload.username.trim().toLowerCase()) {
        SimpleDialogComponent.showAlert(
            'O nome de usuário não corresponde ao usuário logado!',
            subMessage: 'Campo obrigatório!',
            dialogColor: DialogColor.DANGER);
        return false;
      }
    }

    return true;
  }

  void trocaSenha() async {
    if (!validateForm()) {
      return;
    }
    try {
      _simpleLoading.show();
      await _authService.trocaSenha(username, senhaAtual, novaSenha);
      SimpleDialogComponent.showAlert(StatusMessage.SUCCESS);
    } catch (e, s) {
      print('AlterarSenhaPage@trocaSenha $e $s');
      SimpleDialogComponent.showAlert(
          'Não foi possível trocar a senha, verifique as informações preenchidas.',
          subMessage: '$e');
    } finally {
      _simpleLoading.hide();
    }
  }

  bool isAdmin = false;

  @override
  void onActivate(RouterState? previous, RouterState current) {
    if (_authService.authPayload.username == 'admin') {
      isAdmin = true;
    } else {
      username = _authService.authPayload.username;
      isAdmin = false;
    }
  }
}
