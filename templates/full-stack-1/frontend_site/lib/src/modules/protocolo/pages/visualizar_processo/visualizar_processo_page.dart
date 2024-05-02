import 'dart:convert';

import 'package:new_sali_frontend_site/src/shared/components/loading/loading.dart';
import 'package:new_sali_frontend_site/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:new_sali_frontend_site/src/shared/routes/route_paths.dart';
import 'package:ngdart/angular.dart';

import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:new_sali_core/new_sali_core.dart';

@Component(
  selector: 'visualizar-processo-page',
  styleUrls: ['visualizar_processo_page.css'],
  templateUrl: 'visualizar_processo_page.html',
  directives: [
    coreDirectives,
    formDirectives,
  ],
  providers: [],
)
class VisualizaProcessoPage implements OnInit, OnActivate {
  VisualizaProcessoPage(this._router);
  final Router _router;

  Processo processo = Processo.invalido();

  @override
  void ngOnInit() {}

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    processo.codProcesso =
        int.tryParse(getParam(current.parameters, 'cdp') ?? '') ?? -1;
    processo.anoExercicio = getParam(current.parameters, 'ae') ?? '';
    await loadProcesso();
  }

  void irParaNovaConsulta() {
    _router.navigate(
      RoutePaths.consultaProcesso.toUrl(),
      NavigationParams(queryParameters: {}),
    );
  }

  Future<void> loadProcesso() async {
    final loading = SimpleLoading();
    try {
      var protocol = 'http:';

      var port = 3161;
      protocol = html.window.location.protocol;
      var domainWithPort = '$protocol//localhost:$port';
      var path = '/api/v1';

      if (html.window.location.href.contains('127.0.0.1') ||
          html.window.location.href.contains('localhost')) {
        port = 3161;
        domainWithPort = '$protocol//localhost:$port';
      } else if (html.window.location.href
          .contains('10.0.0.66')) {
        path = '/salipublicbackend/api/v1';
        port = 90;
        domainWithPort = '$protocol//10.0.0.66:$port';
      }

      final baseUrl = '$domainWithPort$path';
      final uri = Uri.parse(
          '$baseUrl/protocolo/processos/public/site/${processo.anoExercicio}/${processo.codProcesso}');
      if (processo.codProcesso == -1) {
        throw Exception('Código de processo é inválido!');
      }
      if (int.tryParse(processo.anoExercicio) == null) {
        throw Exception('Ano de exercício do processo é inválido!');
      }
      loading.show();
      final result = await http.get(uri, headers: {
        'Authorization': 'Bearer YWNjZXNzX3Rva2VudfrtwSali',
        'Accept': 'application/json',
        'Content-type': 'application/json;charset=utf-8'
      });
      loading.hide();
      if (result.statusCode != 200) {
        throw Exception('falhar ao consultar o processo, tente mais tarde!');
      }
      processo = Processo.fromMap(jsonDecode(result.body));
    } catch (e, s) {
      loading.hide();
      print('VisualizaProcessoPage@loadProcesso $e $s');
      SimpleDialogComponent.showAlert('Erro: $e');
    }
  }
}
