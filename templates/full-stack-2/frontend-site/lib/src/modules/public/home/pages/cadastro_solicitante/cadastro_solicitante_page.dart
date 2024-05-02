import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend_site/src/modules/public/home/services/extra_service.dart';
import 'package:esic_frontend_site/src/modules/public/home/services/solicitante_service.dart';

import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:esic_frontend_site/src/shared/directives/cnpj_mask_directive.dart';
import 'package:esic_frontend_site/src/shared/directives/cpf_mask_directive.dart';
import 'package:esic_frontend_site/src/shared/directives/mask_directive.dart';
import 'package:esic_frontend_site/src/shared/directives/value_accessors/custom_form_directives.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:ngdart/angular.dart';

import 'dart:html' as html;

import 'package:ngforms/src/directives/radio_control_value_accessor.dart';
import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'cadastro-solicitante-page',
  templateUrl: 'cadastro_solicitante_page.html',
  styleUrls: ['cadastro_solicitante_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    CpfMaskDirective,
    CnpjMaskDirective,
    MaskDirective,
  ],
  providers: [
    ClassProvider(SolicitanteService),
    ClassProvider(ExtraService),
    ClassProvider(RadioControlRegistry),
  ],
)
class CadastroSolicitantePage implements OnInit, OnActivate {
  final SolicitanteService solicitanteService;
  final ExtraService extraService;

  bool isSaved = false;
  SimpleLoading simpleLoading = SimpleLoading();

  final Router _router;

  final Location _location;

  @ViewChild('page')
  html.DivElement? pageContainer;
  String? errorMessage;

  CadastroSolicitantePage(this.solicitanteService, this.extraService,
      this._router, this._location) {
    solicitante.estado = Estado(nome: 'Rio de Janeiro', sigla: 'RJ', id: 11);
  }

  List<FaixaEtaria> faixaEtarias = <FaixaEtaria>[];
  List<Escolaridade> escolaridades = <Escolaridade>[];
  List<TipoTelefone> tipoTelefones = <TipoTelefone>[];
  List<Estado> estados = <Estado>[];

  bool isNew = true;

  Solicitante solicitante = Solicitante(
    nome: '',
    bairro: '',
    chave: '',
    cpfCnpj: '',
    tipoPessoa: 'F',
    email: '',
    cidade: 'city',
    cep: '',
    dataCadastro: DateTime.now(),
    confirmado: 0,
    logradouro: '',
    numero: '',
    uf: '',
  );

  RadioButtonState _pessoaFisica = RadioButtonState(true, 'F');
  RadioButtonState _pessoaJuridica = RadioButtonState(false, 'J');

  RadioButtonState get pessoaFisica => _pessoaFisica;
  RadioButtonState get pessoaJuridica => _pessoaJuridica;

  set pessoaFisica(RadioButtonState ps) {
    _pessoaFisica = ps;
    solicitante.tipoPessoa = ps.value;
  }

  set pessoaJuridica(RadioButtonState pj) {
    _pessoaJuridica = pj;
    solicitante.tipoPessoa = pj.value;
  }

  String confirmEmail = '';

  String get emailIsEquals =>
      solicitante.email != confirmEmail ? 'block' : 'none';

  String confirmeSenha = '';

  String get senhaIsEquals =>
      solicitante.chave != confirmeSenha ? 'block' : 'none';

  void save() async {
    if (solicitante.nome.trim().isEmpty) {
      SimpleDialogComponent.showAlert('Nome não pode estar vazio!');
      return;
    }

    if (!solicitante.isFisica) {
      if (!CNPJValidator.isValid(solicitante.cpfCnpj)) {
        SimpleDialogComponent.showAlert('CNPJ inválido!');
        return;
      }
    } else {
      if (!CPFValidator.isValid(solicitante.cpfCnpj)) {
        SimpleDialogComponent.showAlert('CPF inválido!');
        return;
      }
    }

    if (solicitante.idFaixaEtaria == null) {
      SimpleDialogComponent.showAlert('O Campo "Faixa Etária" é obrigatório !');
      return;
    }

    if (solicitante.idEscolaridade == null) {
      SimpleDialogComponent.showAlert('O Campo "Escolaridade" é obrigatório !');
      return;
    }

    if (solicitante.email.trim().isEmpty) {
      SimpleDialogComponent.showAlert('O Campo "E-mail" não pode estar vazio!');
      return;
    }
    if (isNew) {
      if (solicitante.chave.length < 6) {
        SimpleDialogComponent.showAlert(
            'A senha não pode estar vazia e deve ter pelo menos 6 caracteres!');
        return;
      }

      if (solicitante.chave != confirmeSenha) {
        SimpleDialogComponent.showAlert(
            'O Campo "Senha" e "Confirme Senha" tem que ser iguais!');
        return;
      }
    }

    if (solicitante.email != confirmEmail) {
      SimpleDialogComponent.showAlert(
          'O Campo "E-mail" e "Confirme E-mail" tem que ser iguais!');
      return;
    }

    try {
      isSaved = false;
      simpleLoading.show(target: pageContainer);
      solicitante.cpfCnpj =
          solicitante.cpfCnpj.replaceAll(RegExp(r'[^0-9]'), '');

      if (isNew) {
        await solicitanteService.insert(solicitante);
      } else {
        await solicitanteService.update(solicitante);
      }
      isSaved = true;
    } catch (e, s) {
      print('CadastroSolicitantePage@save $e $s');
      SimpleDialogComponent.showAlert('Erro ao realizar o cadastro! $e',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  void irParaLogin() {
    _router.navigate(RoutePaths.login.toUrl());
  }

  void voltar() {
    _location.back();
  }

  void irParaInicio() {
    _router.navigate(RoutePaths.bemVindo.toUrl());
  }

  Future<void> getAllFaixaEtaria() async {
    try {
      simpleLoading.show(target: pageContainer);
      faixaEtarias = await extraService.getAllFaixaEtaria();
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar faixa etarias',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> getAllEscolaridade() async {
    try {
      simpleLoading.show(target: pageContainer);
      escolaridades = await extraService.getAllEscolaridade();
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar escolaridade',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> getAllTipoTelefone() async {
    try {
      simpleLoading.show(target: pageContainer);
      tipoTelefones = await extraService.getAllTipoTelefone();
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar tipos de Telefone',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> getAllEstados() async {
    try {
      simpleLoading.show(target: pageContainer);
      estados = await extraService.getAllEstados();
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar estados',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> getSolicitante() async {
    try {
      simpleLoading.show(target: pageContainer);
      solicitante = await solicitanteService.getByToken();
      confirmEmail = solicitante.email;
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar Solicitante',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  @override
  void ngOnInit() async {
    // print('CadastroSolicitantePage@ngOnInit');
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await getAllFaixaEtaria();
    await getAllEscolaridade();
    await getAllTipoTelefone();
    await getAllEstados();

    if (current.parameters['id'] == ':id' ||
        current.parameters['id'] == 'new') {
      isNew = true;
    } else {
      //final id = int.parse(current.parameters['id']!);
      isNew = false;
      await getSolicitante();
    }
  }
}
