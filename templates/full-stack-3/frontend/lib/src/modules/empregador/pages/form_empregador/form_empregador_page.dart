import 'dart:async';
import 'dart:html' as html;
import 'package:sibem_frontend/sibem_frontend.dart';
import 'package:sibem_frontend/src/modules/divisao_cnae/pages/lista_divisao_cnae/lista_divisao_cnae_page.dart';

@Component(
  selector: 'form-empregador-page',
  templateUrl: 'form_empregador_page.html',
  styleUrls: ['form_empregador_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
    ListaDivisaoCnaePage,
    CpfMaskDirective,
  ],
  exports: [],
)
class FormEmpregadorPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final EmpregadorService _empregadorService;
  final UfService _ufService;
  final MunicipioService _municipioService;
  final Router _router;
  final Location _location;

  bool isNew = true;

  final html.Element hostElement;

  @ViewChild('modalCnae')
  CustomModalComponent? modalCnae;

  @ViewChild('listaCnae')
  ListaDivisaoCnaePage? listaCnae;

  var item = Empregador.invalidJuridica();

  FormEmpregadorPage(
      this.notificationComponentService,
      this.hostElement,
      this._empregadorService,
      this._router,
      this._location,
      this._ufService,
      this._municipioService);

  DataFrame<Uf> ufs = DataFrame<Uf>.newClear();
  DataFrame<Municipio> municipios = DataFrame<Municipio>.newClear();
  List<String> tiposLogradoouro = listaTiposLogradouroPmro;
  List<String> tiposEndereco = listaTipoEnderecoPmro;

  /// obtem um empregador
  Future<void> getById(int id) async {
    final simpleLoading = SimpleLoading();

    try {
      simpleLoading.show(target: hostElement);
      var emp = await _empregadorService.getById(id);
      //item.pessoaJuridica?.telefones
      if (emp.isPessoaFisica && emp.pessoaFisica != null) {
        emp.telefones = emp.pessoaFisica!.telefones;
        emp.enderecos = emp.pessoaFisica!.enderecos;
      } else if (emp.isPessoaJuridica && emp.pessoaJuridica != null) {
        emp.telefones = emp.pessoaJuridica!.telefones;
        emp.enderecos = emp.pessoaJuridica!.enderecos;
      }
      if (emp.enderecos.isNotEmpty && emp.enderecos.first.idUf != null) {
        await loadMunicipio(idUf: emp.enderecos.first.idUf!);
      }

      item = emp;
      // print('getById  item.enderecos ${item.enderecos.first}');

      //print('getById telefones ${item.pessoaJuridica?.telefones}');
    } catch (e, s) {
      print('FormEmpregadorPage@getById $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> loadUfs() async {
    final simpleLoading = SimpleLoading();
    try {
      simpleLoading.show(target: hostElement);
      ufs = await _ufService.all(Filters(limit: 30));
    } catch (e, s) {
      print('FormEmpregadorPage@loadUfs $e $s');
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
      simpleLoading.show(target: hostElement);
      //, idUf: idUf
      municipios = await _municipioService.getAllByIdUf(idUf);
    } catch (e, s) {
      print('FormEmpregadorPage@loadMunicipio $e $s');
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  bool validateForm() {
    if (item.contato.trim().length < 3) {
      SimpleDialogComponent.showAlert(
          'O contato não pode ficar vazio e deve ter pelo menos 3 caracteres!',
          subMessage: 'Campo obrigatório!',
          dialogColor: DialogColor.DANGER,
          okAction: () {});
      return false;
    }
    return true;
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
          simpleLoading.show(target: hostElement);
        }
        if (isNew) {
          await _empregadorService.insert(item);
        } else {
          await _empregadorService.update(item);
        }
        notificationComponentService.notify(
            'Empregador ${isNew ? 'cadastrado' : 'atualizado'} com sucesso.');

        _router.navigate(RoutePaths.listaEmpregador.toUrl());
      } catch (e, s) {
        print('FormEmpregadorPage@load $e $s');
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

    final idParam = current.parameters['id'];
    final isWeb = current.queryParameters['isWeb'];
    final id = idParam == null ? null : int.tryParse(idParam);

    if (idParam == 'new') {
      if (isWeb == 'true' && RoutePaths.areaTransferencia is EmpregadorWeb) {
        loadFromEmpregadorWeb();
      } else {
        await loadMunicipio();
        item = Empregador.invalidJuridica();
      }
      isNew = true;
    } else if (id != null) {
      isNew = false;
      await getById(id);
    }
  }

  void loadFromEmpregadorWeb() async {
    if (RoutePaths.areaTransferencia is EmpregadorWeb) {
      final empregadorWeb = RoutePaths.areaTransferencia as EmpregadorWeb;
      await loadMunicipio(idUf: empregadorWeb.idUf);

      if (empregadorWeb.tipo == 'fisica') {
        item = Empregador.invalidFisica();
        item.pessoaFisica!.cpf = empregadorWeb.cpfOrCnpj;
        item.pessoaFisica!.rg = empregadorWeb.rg;
        item.pessoaFisica!.dataEmissao = empregadorWeb.dataEmissao;
        item.pessoaFisica!.orgaoEmissor = empregadorWeb.orgaoEmissor;
        item.pessoaFisica!.idUfOrgaoEmissor = empregadorWeb.idUfOrgaoEmissor;
        item.pessoaFisica!.sexo = empregadorWeb.sexo!;
        item.pessoaFisica!.estadoCivil = empregadorWeb.estadoCivil!;
        item.pessoaFisica!.dataNascimento = empregadorWeb.dataNascimento!;
        item.pessoaFisica!.pis = empregadorWeb.pis;
      } else if (empregadorWeb.tipo == 'juridica') {
        item = Empregador.invalidJuridica();
        item.pessoaJuridica!.cnpj = empregadorWeb.cpfOrCnpj;
        item.pessoaJuridica!.nomeFantasia = empregadorWeb.nomeFantasia ?? '';
        item.pessoaJuridica!.inscricaoEstadual =
            empregadorWeb.inscricaoEstadual ?? '';
      }

      item.isFromWeb = true;
      item.nome = empregadorWeb.nome;
      item.ativo = true;
      item.contato = empregadorWeb.contato ?? '';
      item.idDivisaoCnae = empregadorWeb.idCnae;
      item.nomeCnae = empregadorWeb.nomeCnae;
      item.observacao = empregadorWeb.observacao;
      item.emailPrincipal = empregadorWeb.emailPrincipal;
      // telefones
      item.telefones = [
        Telefone(
            id: -1,
            idPessoa: -1,
            tipo: empregadorWeb.tipoTelefone,
            numero: empregadorWeb.telefone)
      ];
      // enderecos
      item.enderecos = [
        Endereco(
          cep: empregadorWeb.cep,
          tipo: empregadorWeb.tipoEndereco,
          //33 BRASIL
          idPais: 33,
          //20 RIO DE JANEIRO
          idUf: empregadorWeb.idUf,
          //3242 city
          idMunicipio: empregadorWeb.idMunicipio,
          tipoLogradouro: empregadorWeb.tipoLogradouro,
          logradouro: empregadorWeb.logradouro,
          numero: empregadorWeb.numeroEndereco,
          nomeBairro: empregadorWeb.bairro,
          complemento: empregadorWeb.complementoEndereco,
          validacao: false,
        )
      ];
      item.observacaoValidacao = empregadorWeb.observacaoValidacao;
      /// preenche os dados de endereço para 
      if (empregadorWeb.isPessoaFisica) {
        item.pessoaFisica!.telefones = item.telefones;
        item.pessoaFisica!.enderecos = item.enderecos;
      } else if (empregadorWeb.isPessoaJuridica) {
        item.pessoaJuridica!.telefones = item.telefones;
        item.pessoaJuridica!.enderecos = item.enderecos;
      }
    }
  }

  void back() {
    _location.back();
  }

  void onChangeTipoPessoa(String? tipo) {
    if (tipo == 'fisica') {
      item = Empregador.invalidFisica();
      print(
          'onChangeTipoPessoa tipo: ${item.enderecos.first.tipo} | tipoLogradouro: ${item.enderecos.first.tipoLogradouro}');
    } else if (tipo == 'juridica') {
      item = Empregador.invalidJuridica();
      print(
          'onChangeTipoPessoa tipo: ${item.enderecos.first.tipo} | tipoLogradouro: ${item.enderecos.first.tipoLogradouro}');
    }
  }

  void openModalCnae() {
    modalCnae?.open();
    listaCnae?.load();
  }

  void onSelectCnae(DivisaoCnae cnae) {
    item.idDivisaoCnae = cnae.id;
    item.nomeCnae = cnae.nome;
    modalCnae?.close();
  }

  void addTelefone() {
    if (item.telefones.length < 3) {
      item.telefones.add(Telefone.invalid());
    }
  }

  void rmTelefone(Telefone tel) {
    if (item.telefones.length > 1) {
      item.telefones.remove(tel);
    }
  }

  void addEndereco() {
    if (item.enderecos.isEmpty) {
      item.enderecos.add(Endereco.invalid());
    }
  }

  void rmEndereco(Endereco end) {
    if (item.enderecos.length > 1) {
      item.enderecos.remove(end);
    }
  }

  void onUfChanged(Endereco endereco, int idUf) {
    endereco.idMunicipio = -1;
    loadMunicipio(idUf: idUf);
  }

  void cancelar() {
    // if (item.isFromWeb == true) {
    //   _router.navigate(RoutePaths.listaEmpregadorWeb.toUrl());
    // }
    _location.back();
  }
}
