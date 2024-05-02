// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html';
import 'package:chartjs2/chartjs.dart';
import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/utils/flatcolor.dart';

import 'package:new_sali_frontend/new_sali_frontend.dart';

@Component(
  selector: 'processos-ano-comp',
  templateUrl: 'processos_ano_comp.html',
  styleUrls: ['processos_ano_comp.css'],
  directives: [
    routerDirectives,
  ],
)
class ProcessosAnoComp {
  final EstatisticaService _estatisticaService;
  final AuthService _authService;

  @ViewChild('canvas')
  CanvasElement? canvas;

  @ViewChild('canvasContainer')
  Element? canvasContainer;

  Element rootElement;

  ProcessosAnoComp(
      this._estatisticaService, this._authService, this.rootElement);

  List<Map<String, dynamic>> items = [];
  Filters filtros = Filters(forceRefresh: false);

  Future<void> load([bool preClear = false]) async {
    final loading = SimpleLoading();
    try {
      loading.show(target: rootElement);
      items = await _estatisticaService.totalProcessosPorAno(filtros);
      initGrafico(preClear);
    } catch (e, s) {
      print('ProcessosAnoComp@load $e $s');
    } finally {
      loading.hide();
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

    final labels = items.map((e) => e['ano_exercicio']).toList();
    final total = items.map((e) => e['total']).toList();

    if (total.isEmpty) {
      return;
    }

    final linearChartDataata =
        LinearChartData(labels: labels, datasets: <ChartDataSets>[
      ChartDataSets(
          // pointRadius: 5,
          //  borderRadius:5,
          label: 'processos por ano',
          backgroundColor:
              FlatColor.generate2(length: total.length), //'#a009ed',
          data: total)
    ]);

    final config = ChartConfiguration(
        type: 'bar',
        data: linearChartDataata,
        options: ChartOptions(
          responsive: true,
          maintainAspectRatio: false,
          legend: ChartLegendOptions(display: false),
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
