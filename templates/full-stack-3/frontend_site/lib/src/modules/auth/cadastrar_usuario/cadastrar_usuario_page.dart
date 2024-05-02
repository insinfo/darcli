import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'cadastrar-usuario-page',
  templateUrl: 'cadastrar_usuario_page.html',
  styleUrls: ['cadastrar_usuario_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    FooterComponent,
    NavbarComponent,
    MaskDirective,
  ],
  exports: [],
)
class CadastrarUsuarioPage implements OnInit, OnActivate {
  // ignore: unused_field
  final Router _router;
  // ignore: unused_field
  final Location _location;
  final AuthService authService;
  final UsuarioService _usuarioService;

  UsuarioWeb usuario = UsuarioWeb(
    id: -1,
    confirmado: 0,
    dataCadastro: DateTime.now(),
    chave: '',
    login: '',
    nome: '',
    email: '',
    tipo: '',
    telefone: '',
    tipoPessoa: '',
  );

  int step = 0;

  CadastrarUsuarioPage(
      this.authService, this._router, this._location, this._usuarioService);

  void irParaCadastro(String tipo) {
    if (tipo == 'Candidato') {
      usuario.tipoPessoa = 'fisica';
    } else if (tipo == 'Empregador') {
      usuario.tipoPessoa = 'juridica';
    }
    _location
        .go(RoutePaths.cadastrarUsuario.toUrl(queryParameters: {'tipo': tipo}));
    usuario.tipo = tipo;
    step = 1;
  }

  @override
  void ngOnInit() {
    //
  }

  bool validateForm() {
    if (usuario.login.trim().isEmpty) {
      SimpleDialogComponent.showAlert(
          'O campo ${usuario.isCandidato ? 'CPF' : 'CNPJ'} não pode esta vazio!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER);
      return false;
    }

    if (usuario.isCandidato == true && !CpfUtil().validate(usuario.login)) {
      SimpleDialogComponent.showAlert(
          'O campo CPF tem que ser preenchido com um número valido!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER);
      return false;
    }

    if (usuario.tipoPessoa == '') {
      SimpleDialogComponent.showAlert('O Tipo Pessoa tem que ser selecionado!',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }

    if (usuario.tipoPessoa == 'juridica' && !CnpjUtil.isValid(usuario.login)) {
      SimpleDialogComponent.showAlert(
          'O campo CNPJ tem que ser preenchido com um número valido!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER);
      return false;
    }

    if (usuario.tipoPessoa == 'fisica' && !CpfUtil().validate(usuario.login)) {
      SimpleDialogComponent.showAlert(
          'O campo CPF tem que ser preenchido com um número valido!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER);
      return false;
    }

    if (usuario.chave != usuario.repeteChave) {
      //'O Campo "Senha" e "Confirme Senha" tem que ser iguais!'
      SimpleDialogComponent.showAlert('As senhas digitadas não coincidem',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }

    if (usuario.email != usuario.repeteEmail) {
      //'O Campo "E-mail" e "Confirme E-mail" tem que ser iguais!'
      SimpleDialogComponent.showAlert('Os e-mails digitados não coincidem',
          subMessage: 'Campo obrigatório!', dialogColor: DialogColor.DANGER);
      return false;
    }

    return true;
  }

  void salvar(NgForm cadastroForm, {bool showLoading = true}) async {
    var isValid = true;
    for (var control in cadastroForm.form!.controls.values) {
      control.markAsTouched();
      control.updateValueAndValidity();
      //so checa se é valido os campos com a directiva customRequired ignorando os campos com a directiva cpfValidator
      if (control.errors != null &&
          control.errors!['validator'] == 'customRequired') {
        isValid = false;
      }
    }

    if (isValid == false) {
      SimpleDialogComponent.showAlert('Preencha os campos obrigatórios!',
          okAction: () => focusFirstInvalidFields(cadastroForm));
    } else {
      final simpleLoading = SimpleLoading();
      try {
        if (!validateForm()) {
          return;
        }
        if (showLoading) {
          simpleLoading.show();
        }

        await _usuarioService.insert(usuario);
        step = 2;
        // notificationComponentService.notify(
        //     'Curso ${isNew ? 'cadastrado' : 'atualizado'} com sucesso.');

        // _router.navigate(RoutePaths.listaCurso.toUrl());
      } catch (e, s) {
        //empregador já está cadastrado
        if ('$e'.contains('empregador já está cadastrado')) {
          SimpleDialogComponent.showAlert('Você já está cadastrado!');
        } else {
          print('CadastrarUsuarioPage@load $e $s');
          SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
              subMessage: '$e $s');
        }
      } finally {
        if (showLoading) {
          simpleLoading.hide();
        }
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) {
    if (current.queryParameters.containsKey('tipo') &&
        ['Candidato', 'Empregador'].contains(current.queryParameters['tipo'])) {
      usuario.tipo = current.queryParameters['tipo']!;
      usuario.tipoPessoa = usuario.isCandidato ? 'fisica' : 'juridica';
      step = 1;
    } else {
      step = 0;
    }
  }

  void irParaLogin() {
    _router.navigate(RoutePaths.login.toUrl());
  }
}
