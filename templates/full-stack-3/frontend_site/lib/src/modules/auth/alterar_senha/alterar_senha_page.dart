import 'package:sibem_frontend_site/sibem_frontend_site.dart';

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

  AlterarSenhaPage(this.router, this._authService) {}

  bool validateForm() {
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

    return true;
  }

  void trocaSenha() async {
    if (!validateForm()) {
      return;
    }
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show();
      await _authService.trocaSenha(username, senhaAtual, novaSenha);
      SimpleDialogComponent.showAlert(StatusMessage.SUCCESS);
      router.navigate(RoutePaths.bemVindo.toUrl());
    } catch (e, s) {
      print('AlterarSenhaPage@trocaSenha $e $s');
      SimpleDialogComponent.showAlert(
          'Não foi possível trocar a senha, verifique as informações preenchidas.',
          subMessage: '$e');
    } finally {
      simpleLoading.hide();
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) {}
}
