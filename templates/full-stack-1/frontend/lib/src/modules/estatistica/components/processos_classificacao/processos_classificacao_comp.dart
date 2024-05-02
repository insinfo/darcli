// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html';
import 'package:chartjs2/chartjs.dart';
import 'package:new_sali_core/new_sali_core.dart';

import 'package:new_sali_frontend/new_sali_frontend.dart';

@Component(
  selector: 'processos-classificacao-comp',
  templateUrl: 'processos_classificacao_comp.html',
  styleUrls: ['processos_classificacao_comp.css'],
  directives: [
    coreDirectives,
    NoDataComponent,
  ],
)
class ProcessosClassificacaoComp {
  final EstatisticaService _estatisticaService;
  final AuthService _authService;

  @ViewChild('canvas')
  CanvasElement? canvas;

  // @ViewChild('canvasContainer')
  // Element? canvasContainer;

  ProcessosClassificacaoComp(this._estatisticaService, this._authService);

  List<Map<String, dynamic>> items = [];
  Filters filtros = Filters(forceRefresh: false);

  Future<void> load([bool preClear = false]) async {
    try {
      items = await _estatisticaService.processosPorClassificacao(filtros);
      initGrafico(preClear);
    } catch (e, s) {
      print('ProcessosClassificacaoComp@load $e $s');
    }
  }

  void reload() {
    load(true);
  }

  void onlyCurrentSetor() {
    filtros.codOrgao = _authService.authPayload.codOrgao;
    filtros.codUnidade = _authService.authPayload.codUnidade;
    filtros.codDepartamento = _authService.authPayload.codDepartamento;
    filtros.codSetor = _authService.authPayload.codSetor;
    filtros.anoExercicio = _authService.authPayload.anoExercicioSetor;
    load(true);
  }

  void allSetor() {
    filtros.codOrgao = null;
    filtros.codUnidade = null;
    filtros.codDepartamento = null;
    filtros.codSetor = null;
    filtros.anoExercicio = null;
    load(true);
  }

  void initGrafico([bool preClear = false]) {
    if (preClear && canvas != null) {
      var parent = canvas!.parent;
      parent!.innerHtml = '';
      canvas = CanvasElement()
        ..width = 500
        ..height = 400;
      parent.append(canvas!);
    }

    final labels = items.map((e) => e['nom_classificacao']).toList();
    final total = items.map((e) => e['total']).toList();

    if (total.isEmpty) {
      return;
    }

    final linearChartDataata =
        LinearChartData(labels: labels, datasets: <ChartDataSets>[
      ChartDataSets(
          label: 'Processos por Classificação',
          borderColor:
              '#ae67d5', //FlatColor.generate(1).first, //'#7a7bdc' '#a009ed',
          data: total)
    ]);

    final config = ChartConfiguration(
        type: 'line',
        data: linearChartDataata,
        options: ChartOptions(
          responsive: true,
          maintainAspectRatio: false,
          legend: ChartLegendOptions(display: false),
          //ChartYAxe
          scales: ChartScales(xAxes: [
            ChartXAxe(display: false),
          ]),
        ));

    Chart(canvas, config);
  }

  void downloadAsPng() {
    var svgUrl = canvas!.toDataUrl('image/png');
    var downloadLink = AnchorElement(href: svgUrl);
    downloadLink.download = "grafico.png";
    downloadLink.click();
  }
}
