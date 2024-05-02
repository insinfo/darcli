// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html';

import 'package:chartjs2/chartjs.dart';

import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:new_sali_frontend/src/shared/js_interop/canvas2svg.dart';
import 'package:new_sali_frontend/src/shared/utils/flatcolor.dart';

@Component(
  selector: 'processos-situacao-comp',
  templateUrl: 'processos_situacao_comp.html',
  styleUrls: ['processos_situacao_comp.css'],
  directives: [
    routerDirectives,
  ],
)
class ProcessosSituacaoComp {
  final EstatisticaService _estatisticaService;
  final AuthService _authService;

  @ViewChild('canvas')
  CanvasElement? canvas;

  @ViewChild('canvasContainer')
  Element? canvasContainer;

  Element rootElement;

  ProcessosSituacaoComp(
    this._estatisticaService,
    this._authService,
    this.rootElement,
  );

  final SimpleLoading _simpleLoading = SimpleLoading();

  List<Map<String, dynamic>> items = [];
  Filters filtros = Filters(forceRefresh: false);

  Future<void> load([bool preClear = false]) async {
    try {
      _simpleLoading.show(target: rootElement);
      items = await _estatisticaService.processosPorSituacao(filtros);
      initChart(preClear);
    } catch (e, s) {
      print('ProcessosSituacaoComp@load $e $s');
    } finally {
      _simpleLoading.hide();
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

  List<dynamic> get labels => items.map((e) => e['nom_situacao']).toList();
  List<dynamic> get total => items.map((e) => e['total']).toList();

  void initChart([bool preClear = false]) {
    // print('ProcessosSituacaoComp@initChart $total $labels');
    if (total.isEmpty) {
      return;
    }
    if (preClear && canvas != null) {
      var parent = canvas!.parent;
      parent!.innerHtml = '';
      canvas = CanvasElement()
        ..width = 500
        ..height = 400;
      parent.append(canvas!);
    }

    var linearChartData =
        LinearChartData(labels: labels, datasets: <ChartDataSets>[
      ChartDataSets(
          // pointRadius: 5,
          //  borderRadius:5,
          label: 'processos por situacao',
          backgroundColor: FlatColor.generate2(
              length: total.length, inverse: false), //'#a009ed',
          data: total)
    ]);

    var chartConfiguration = ChartConfiguration(
        type: 'pie',
        data: linearChartData,
        options: ChartOptions(
          // animation: false,
          responsive: true,
          maintainAspectRatio: false,
          legend: ChartLegendOptions(display: true),
        ));

    Chart(canvas, chartConfiguration);
  }

  void downloadSVG() {
    if (total.isEmpty) {
      return;
    }
    var _canvas = CanvasElement();
    _canvas.style.display = 'none';
    document.body!.append(_canvas);
    _canvas.width = 500;
    _canvas.height = 400;

    var c2Ss = C2S(C2SOptions(
      width: 500,
      height: 400,
      ctx: _canvas.context2D,
      canvas: _canvas,
    ));

    var data = LinearChartData(labels: labels, datasets: <ChartDataSets>[
      ChartDataSets(
          label: 'processos por situacao',
          backgroundColor: FlatColor.generate2(
              length: total.length, inverse: false), //'#a009ed',
          data: total)
    ]);

    var configuration = ChartConfiguration(
        type: 'pie',
        data: data,
        options: ChartOptions(
          // animation: false,
          responsive: false,
          maintainAspectRatio: false,
          legend: ChartLegendOptions(display: true),
        ));

    Chart(c2Ss, configuration);

    Future.delayed(Duration(milliseconds: 1000), () {
      var svgData = c2Ss.getSerializedSvg();
      var svgBlob = Blob([svgData], "image/svg+xml;charset=utf-8");
      var svgUrl = Url.createObjectUrl(svgBlob);
      var downloadLink = AnchorElement(href: svgUrl);
      downloadLink.download = "grafico.svg";
      downloadLink.click();
      _canvas.remove();
    });
  }

  void downloadAsPng() {
    var svgUrl = canvas!.toDataUrl('image/png');
    var downloadLink = AnchorElement(href: svgUrl);
    downloadLink.download = "grafico.png";
    downloadLink.click();
  }
}
