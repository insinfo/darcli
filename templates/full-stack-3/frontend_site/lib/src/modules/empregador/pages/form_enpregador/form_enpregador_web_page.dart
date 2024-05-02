import 'package:sibem_frontend_site/sibem_frontend_site.dart';

@Component(
  selector: 'form-enpregador-web-page',
  templateUrl: 'form_enpregador_web_page.html',
  styleUrls: ['form_enpregador_web_page.css'],
  directives: [
    coreDirectives,
    routerDirectives,
    customFormDirectives,
  ],
  exports: [RoutePaths, Routes],
)
class FormEnpregadorWebPage implements OnActivate {
  final UfService _ufService;
  final MunicipioService _municipioService;
  final EmpregadorWebService _empregadorWebService;
  final DivisaoCnaeService _divisaoCnaeService;
  final AuthService authService;

  var step = 0;

  var item = EmpregadorWeb.invalidJuridica();

  DataFrame<Uf> ufs = DataFrame<Uf>.newClear();
  DataFrame<Municipio> municipios = DataFrame<Municipio>.newClear();
  DataFrame<DivisaoCnae> cnaes = DataFrame<DivisaoCnae>.newClear();
  List<String> tiposLogradoouro = listaTiposLogradouroPmro;
  List<String> tiposEndereco = listaTipoEnderecoPmro;

  FormEnpregadorWebPage(this._empregadorWebService, this._ufService,
      this._municipioService, this._divisaoCnaeService, this.authService) {
    item.tipoEndereco = 'Comercial';
  }

  String customLabelCnae(Map<String, dynamic> item) {
    return '${item[DivisaoCnae.secaoCol]} - ${item[DivisaoCnae.nomeCol]}';
  }

  bool validateForm() {
    if (item.nome.trim().length < 3) {
      SimpleDialogComponent.showAlert(
          'O nome não pode ficar vazio e deve ter pelo menos 3 caracteres!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    if (item.idCnae == -1) {
      SimpleDialogComponent.showAlert('Selecione o CNAE!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }

    return true;
  }

  Future<void> checkCadastro(NgForm checkForm) async {
    var isValid = true;
    for (var control in checkForm.form!.controls.values) {
      control.markAsTouched();
      control.updateValueAndValidity();
      //so checa se é valido os campos com a directiva customRequired ignorando os campos com a directiva cpfValidator
      if (control.errors != null &&
          control.errors!['validator'] == 'customRequired') {
        isValid = false;
      }
    }

    if (isValid == false) {
      focusFirstInvalidFields(checkForm);
    } else {
      final simpleLoading = SimpleLoading();
      try {
        final cand = await _empregadorWebService.getByCpfOrCnpj(item.cpfOrCnpj);
        if (cand.statusValidacao == EmpregadorStatusValidacao.validado) {
          SimpleDialogComponent.showAlert('Você já fez o seu Pre-cadastro!');
        } else {
          SimpleDialogComponent.showAlert(
              'Seu pré-cadastro já foi feito e está aguardando você comparecer no Banco de Empregos ou entrar em contato por telefone para finalizá-lo!');
        }
      } on NotFoundException {
        step = 1;
      } catch (e, s) {
        print('FormCandidatoPage@load $e $s');
        SimpleDialogComponent.showAlert('Falha ao verificar o CPF/CNPJ',
            subMessage: '$e');
      } finally {
        simpleLoading.hide();
      }
    }
  }

  Future<void> salvar(NgForm cadastroForm, {bool showLoading = true}) async {
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
        await _empregadorWebService.insert(item);
        step = 2;
      } catch (e, s) {
        print('FormEnpregadorWebPage@load $e $s');
        SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
            subMessage: '$e $s');
      } finally {
        if (showLoading) {
          simpleLoading.hide();
        }
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await loadUfs();
    await loadMunicipio();
    await loadCnaes();

    item.cpfOrCnpj = authService.authPayload.login;
    item.nome = authService.authPayload.nome;
  }

  Future<void> loadUfs() async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show();
      ufs = await _ufService.all(Filters(limit: 30));
    } catch (e, s) {
      print('FormCandidatoPage@loadUfs $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  /// idUf = 20 = Rio de Janeiro
  Future<void> loadMunicipio({int idUf = 20}) async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show();
      //, idUf: idUf
      municipios = await _municipioService.getAllByIdUf(idUf);
    } catch (e, s) {
      print('FormCandidatoPage@loadMunicipio $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> loadCnaes() async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show();
      cnaes = await _divisaoCnaeService.all(Filters(limit: 100));
    } catch (e, s) {
      print('FormCandidatoPage@loadCnaes $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  void onUfChanged(int idUf) {
    item.idMunicipio = -1;
    loadMunicipio(idUf: idUf);
  }

  void onChangeTipoPessoa(String? tipo) {
    if (tipo == 'fisica') {
      item = EmpregadorWeb.invalidFisica();
    } else if (tipo == 'juridica') {
      item = EmpregadorWeb.invalidJuridica();
    }
  }
}
