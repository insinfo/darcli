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
  selector: 'detalhe-solicitacao-page',
  templateUrl: 'detalhe_solicitacao_page.html',
  styleUrls: ['detalhe_solicitacao_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  providers: [ClassProvider(SolicitacaoService)],
)
class DetalheSolicitacaoPage implements OnActivate {
  final SolicitacaoService _solicitacaoService;
  final SimpleLoading _simpleLoading = SimpleLoading();

  @ViewChild('page')
  html.DivElement? pageContainer;

  DetalheSolicitacaoPage(this._solicitacaoService);

  Solicitacao solicitacao = Solicitacao(
    idsolicitante: 1,
    numProtocolo: 0,
    anoProtocolo: 0,
    idTipoSolicitacao: 1,
    situacao: 'A',
    formaRetorno: 'E',
    dataSolicitacao: DateTime.now(),
    textoSolicitacao: '',
    dataPrevisaoResposta: DateTime.now().add(Duration(days: 20)),
    resposta: '',
  );

  Future<void> getByIdOfPessoa(int id) async {
    try {
      _simpleLoading.show(target: pageContainer);
      solicitacao = await _solicitacaoService.getByIdOfPessoa(id);
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao enviar a Solicitação.',
          subMessage: '$e $s');
    } finally {
      _simpleLoading.hide();
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    var id = RoutePaths.getId(current.parameters);
    if (id != null) {
      await getByIdOfPessoa(id);
    }
  }

  // void irParaInicio() {
  //   _router.navigate(RoutePaths.home.toUrl());
  // }
}
