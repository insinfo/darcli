import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend_site/src/modules/private/solicitacao/services/solicitacao_service.dart';

import 'package:esic_frontend_site/src/shared/components/loading/loading.dart';
import 'package:esic_frontend_site/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:esic_frontend_site/src/shared/route_paths.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/angular_forms.dart';
import 'package:ngrouter/ngrouter.dart';
import 'dart:html' as html;

@Component(
    selector: 'cadastro-solicitacao-page',
    templateUrl: 'cadastro_solicitacao_page.html',
    styleUrls: [
      'cadastro_solicitacao_page.css'
    ],
    directives: [
      coreDirectives,
      formDirectives,
    ],
    providers: [
      ClassProvider(SolicitacaoService)
    ])
class CadastroSolicitacaoPage {
  final SolicitacaoService _solicitacaoService;
  final SimpleLoading _simpleLoading = SimpleLoading();
  bool isSaved = false;
  final Router _router;

  @ViewChild('page')
  html.DivElement? pageContainer;

  CadastroSolicitacaoPage(this._solicitacaoService, this._router);

  Solicitacao solicitacao = Solicitacao(
    idsolicitante: 1,
    numProtocolo: 1,
    anoProtocolo: DateTime.now().year,
    idTipoSolicitacao: 1,
    situacao: 'A',
    formaRetorno: 'E',
    dataSolicitacao: DateTime.now(),
    textoSolicitacao: '',
    dataPrevisaoResposta: DateTime.now().add(Duration(days: 20)),
    resposta: '',
  );

  Future<void> save() async {
    try {
      _simpleLoading.show(target: pageContainer);
      await _solicitacaoService.insert(solicitacao);
      isSaved = true;
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao enviar a Solicitação.',
          subMessage: '$e $s');
    } finally {
      _simpleLoading.hide();
    }
  }

  void irParaInicio() {
    _router.navigate(RoutePaths.bemVindo.toUrl());
  }
}
