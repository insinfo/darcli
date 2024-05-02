import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend/src/modules/solicitante/services/extra_service.dart';
import 'package:esic_frontend/src/shared/directives/cnpj_mask_directive.dart';
import 'package:esic_frontend/src/shared/directives/cpf_mask_directive.dart';
import 'package:esic_frontend/src/shared/directives/value_accessors/custom_form_directives.dart';
import 'package:esic_frontend/src/shared/services/auth_service.dart';
import 'package:esic_frontend/src/modules/solicitante/services/solicitante_service.dart';
import 'package:esic_frontend/src/shared/components/loading/loading.dart';
import 'package:esic_frontend/src/shared/components/simple_dialog/simple_dialog.dart';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

import 'package:ngrouter/angular_router.dart';
import 'package:ngforms/src/directives/radio_control_value_accessor.dart';

@Component(
  selector: 'form-solicitante-page',
  templateUrl: 'form_solicitante.html',
  styleUrls: ['form_solicitante.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    CpfMaskDirective,
    CnpjMaskDirective,
  ],
  providers: [
    ClassProvider(SolicitanteService),
    ClassProvider(ExtraService),
    ClassProvider(RadioControlRegistry),
  ],
)
class FormSolicitantePage implements OnActivate {
  final SolicitanteService service;
  final AuthService authService;
  final ExtraService extraService;

  bool isNew = true;

  bool isSaved = false;
  SimpleLoading simpleLoading = SimpleLoading();

  @ViewChild('page')
  html.DivElement? pageContainer;
  String? errorMessage;

  FormSolicitantePage(this.service, this.authService, this.extraService);

  List<FaixaEtaria> faixaEtarias = <FaixaEtaria>[];
  List<Escolaridade> escolaridades = <Escolaridade>[];
  List<TipoTelefone> tipoTelefones = <TipoTelefone>[];
  List<Estado> estados = <Estado>[];

  Solicitante solicitante = Solicitante(
    nome: '',
    bairro: '',
    chave: '',
    cpfCnpj: '',
    tipoPessoa: '',
    cidade: '',
    cep: '',
    dataCadastro: DateTime.now(),
    confirmado: 0,
    logradouro: '',
    numero: '',
    uf: '',
    email: '',
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

  void save() async {
    // try {
    //   isSaved = false;
    //   simpleLoading.show(target: pageContainer);
    //   if (isNew) {
    //     await service.insert(solicitante);
    //   } else {
    //     await service.update(solicitante);
    //   }
    //   isSaved = true;
    // } catch (e, s) {
    //   print('FormSolicitantePage@save $e $s');
    //   SimpleDialogComponent.showAlert('Erro ao salvar', subMessage: '$e $s');
    // } finally {
    //   simpleLoading.hide();
    // }
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

  Future<void> getSolicitante(int id) async {
    try {
      simpleLoading.show(target: pageContainer);
      errorMessage = '';
      solicitante = await service.getById(id);
    } catch (e) {
      errorMessage = '$e';
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e');
    } finally {
      simpleLoading.hide();
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await getAllFaixaEtaria();
    await getAllEscolaridade();
    await getAllTipoTelefone();
    await getAllEstados();

    var id = current.parameters['id'];
    if (id == 'new') {
      isNew = true;
    } else {
      isNew = false;
      await getSolicitante(int.parse(id!));
    }
  }
}
