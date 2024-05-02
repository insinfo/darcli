import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend/src/modules/solicitacao/services/gera_pdf_solicitacao.dart';
import 'package:esic_frontend/src/modules/solicitante/services/solicitante_service.dart';
import 'package:esic_frontend/src/shared/components/modal_component/modal_component.dart';
import 'package:esic_frontend/src/shared/extensions/selection_api_extension.dart';
import 'package:esic_frontend/src/shared/route_paths.dart';
import 'package:esic_frontend/src/shared/services/auth_service.dart';
import 'package:esic_frontend/src/modules/solicitacao/services/solicitacoes_service.dart';

import 'package:esic_frontend/src/shared/components/loading/loading.dart';
import 'package:esic_frontend/src/shared/components/simple_dialog/simple_dialog.dart';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'form-solicitacao-page',
  templateUrl: 'form_solicitacao.html',
  styleUrls: ['form_solicitacao.css'],
  directives: [
    coreDirectives,
    formDirectives,
    CustomModalComponent,
  ],
  providers: [
    ClassProvider(SolicitacoesService),
    ClassProvider(SolicitanteService),
  ],
)
class FormSolicitacaoPage implements OnActivate {
  final SolicitacoesService solicitacoesService;
  final SolicitanteService solicitanteService;
  final AuthService authService;

  bool isNew = true;

  bool isSaved = false;
  SimpleLoading simpleLoading = SimpleLoading();

  @ViewChild('page')
  html.DivElement? pageContainer;

  @ViewChild('modalResposta')
  CustomModalComponent? modalResposta;

  @ViewChild('modalProrrogar')
  CustomModalComponent? modalProrrogar;

  String? errorMessage;

  final Router _router;

  FormSolicitacaoPage(this.solicitacoesService, this.authService,
      this.solicitanteService, this._router);

  Solicitacao solicitacao = Solicitacao(
    anoProtocolo: DateTime.now().year,
    numProtocolo: -1,
    idTipoSolicitacao: 1,
    situacao: 'A',
    formaRetorno: 'E',
    dataSolicitacao: DateTime.now(),
    dataPrevisaoResposta: DateTime.now().add(Duration(days: 15)),
    idsolicitante: -1,
    resposta: '',
    textoSolicitacao: '',
  );

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

  Future<void> getSolicitante(int id) async {
    try {
      simpleLoading.show(target: pageContainer);
      errorMessage = '';
      solicitante = await solicitanteService.getById(id);
    } catch (e) {
      errorMessage = '$e';
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> getSolicitacao(int id) async {
    try {
      simpleLoading.show(target: pageContainer);
      errorMessage = '';
      solicitacao = await solicitacoesService.getById(id);
    } catch (e, s) {
      print('getSolicitacao $e $s');
      errorMessage = '$e';
      SimpleDialogComponent.showAlert(StatusMessage.ERROR_GENERIC,
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  void download() async {
    await geraPdfSolicitacao(
      solicitacao,solicitante,
      isDownload: true,
      isPrint: false,
    );
  }

  void imprime() async {
    await geraPdfSolicitacao(
      solicitacao,solicitante,
      isDownload: false,
      isPrint: true,
    );
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    var id = current.parameters['id'];
    if (id == 'new') {
      isNew = true;
    } else {
      isNew = false;
      await getSolicitacao(int.parse(id!));
      await getSolicitante(solicitacao.idsolicitante);
    }
  }

  Future<void> prorrogar() async {
    try {
      if (solicitacao.motivoProrrogacao == null) {
        SimpleDialogComponent.showAlert(
            'Motivo Prorrogação não pode ser vazio!');
        return;
      }
      if (solicitacao.motivoProrrogacao!.trim().isEmpty == true) {
        SimpleDialogComponent.showAlert(
            'Motivo Prorrogação não pode ser vazio!');
        return;
      }
      if (solicitacao.motivoProrrogacao!.trim().length < 3) {
        SimpleDialogComponent.showAlert(
            'Motivo Prorrogação deve ter mais de 3 caracteres!');
        return;
      }
      simpleLoading.show();
      await solicitacoesService.prorrogar(solicitacao);
      modalProrrogar?.close();
      await _router.navigate(RoutePaths.solicitacoes.toUrl());
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao prorrogar esta solicitação!',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  Future<void> responder() async {
    try {
      if (solicitacao.resposta.trim().isEmpty == true) {
        SimpleDialogComponent.showAlert('Resposta não pode ser vazio!');
        return;
      }
      if (solicitacao.resposta.trim().length < 3) {
        SimpleDialogComponent.showAlert(
            'Resposta deve ter mais de 3 caracteres!');
        return;
      }

      simpleLoading.show();
      await solicitacoesService.responder(solicitacao);
      modalResposta?.close();
      await _router.navigate(RoutePaths.solicitacoes.toUrl());
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao responder esta solicitação!',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  void handleFileChange(html.FileUploadInputElement inputFile) async {
    if (inputFile.files != null) {
      if (inputFile.files!.length > 4) {
        SimpleDialogComponent.showAlert(
            'Não pode adicionar mais que 5 arquivos!');
        return;
      }

      if (solicitacao.anexos.length > 4) {
        SimpleDialogComponent.showAlert(
            'Não pode adicionar mais que 5 arquivos!');
        return;
      }

      var total = solicitacao.anexos.isNotEmpty == true
          ? solicitacao.anexos.map((e) => e.size).reduce((a, b) => a + b)
          : 0;
      //20 MB = 20971520 Bytes
      if (total > 20971520) {
        SimpleDialogComponent.showAlert(
            'o Limite de upload é de 20 Megabytes!');
        return;
      }
      for (var file in inputFile.files!) {
        final anexo = Anexo(
          idsolicitacao: solicitacao.id,
          //authService.getIdPessoa()
          idusuarioinclusao: -1,
          datainclusao: DateTime.now(),
          nome: file.name,
          size: file.size,
          type: file.type,
          isNew: true,
          bytes: await file.asArrayBuffer(),
        );
        //solicitacao.anexos = [];
        solicitacao.anexos.add(anexo);
      }
    }

    print('handleFileChange anexos ${solicitacao.anexos}');
  }

  void removeAnexo(Anexo anexo) {
    solicitacao.anexos.remove(anexo);
  }
}
