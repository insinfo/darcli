// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html';
import 'package:chartjs2/chartjs.dart';
import 'package:dart_excel/dart_excel.dart';
import 'package:new_sali_core/new_sali_core.dart';

import 'package:new_sali_frontend/src/shared/utils/flatcolor.dart';

import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:js/js.dart';

extension CallbackTickOptions on TickOptions {
  /// Allows assigning a function to be callable from `window.functionName()`
  @JS('callback')
  external set callback2(
      dynamic Function(dynamic value, dynamic index, dynamic values) f);
}

@anonymous
@JS()
abstract class ChartTooltipCallback2 {
  external factory ChartTooltipCallback2();
  // external void beforeTitle([List<ChartTooltipItem> item, dynamic data]);
  // external void title([List<ChartTooltipItem> item, dynamic data]);
  // external void afterTitle([List<ChartTooltipItem> item, dynamic data]);
  // external void beforeBody([List<ChartTooltipItem> item, dynamic data]);
  // external void beforeLabel([ChartTooltipItem tooltipItem, dynamic data]);
  // external void label([ChartTooltipItem tooltipItem, dynamic data]);
  @JS('label')
  external set label(dynamic Function(dynamic tooltipItems, dynamic data) f);

  @JS('title')
  external set title(dynamic Function(dynamic items, dynamic data) f);
  // external void afterLabel([ChartTooltipItem tooltipItem, dynamic data]);
  // external void afterBody([List<ChartTooltipItem> item, dynamic data]);
  // external void beforeFooter([List<ChartTooltipItem> item, dynamic data]);
  // external void footer([List<ChartTooltipItem> item, dynamic data]);
  // external void afterFooter([List<ChartTooltipItem> item, dynamic data]);
}

extension CallbackChartTooltipOptions on ChartTooltipOptions {
  // external ChartTooltipCallback2 get callbacks2;
  @JS('callbacks')
  external set callbacks2(ChartTooltipCallback2 v);
}

@Component(
  selector: 'process-setor-primero-tramite-comp',
  templateUrl: 'process_setor_primero_tramite.html',
  styleUrls: ['process_setor_primero_tramite.css'],
  directives: [
    coreDirectives,
    routerDirectives,
  ],
)
class ProcessSetorPrimeroTramiteComp {
  final EstatisticaService _estatisticaService;
  final AuthService _authService;

  @ViewChild('canvas')
  CanvasElement? canvas;

  @ViewChild('canvasContainer')
  Element? canvasContainer;

  final DateTime now = DateTime.now();

  final Element rootElement;

  ProcessSetorPrimeroTramiteComp(
      this._estatisticaService, this._authService, this.rootElement) {
    meses = FrontUtils.getMonthsFromDayTillNow('${now.year}-01-01');
  }

  List<Map<String, dynamic>> items = [];
  Filters filtros = Filters(forceRefresh: false);

  List<String> meses = [];

  Future<void> load([bool preClear = false]) async {
    //final loading = SimpleLoading();
    try {
      //loading.show(target: rootElement);
      items = await _estatisticaService
          .processByPeriodoSetorPrimeroTramite(filtros);
      initGrafico(preClear);
    } catch (e, s) {
      print('ProcessSetorPrimeroTramiteComp@load $e $s');
    } finally {
      //loading.hide();
    }
  }

  void reload() {
    load(true);
  }

  void changeMes(String? mesIndex) {
    var mIdx = int.tryParse(mesIndex ?? '');
    if (mIdx != null) {
      filtros.inicio = DateTime(now.year, mIdx + 1, 1);
      filtros.fim = DateTime(now.year, (mIdx + 1) + 1, 0);
      load(true);
    }
  }

  void downloadAsXlsx() {
    // Create a new Excel document.
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];

    if (items.isNotEmpty) {
      final totalColunas = 2;
      final totalLinhas = items.length;

      sheet.importList(['mês', 'total'], 1, 1, false);

      for (var i = 1; i < totalLinhas + 1; i++) {
        final col = items[i - 1];

        int firstRow = i + 1;
        int firstColumn = 1;

        sheet.importList(
            [col['nom_setor'], col['total']], firstRow, firstColumn, false);
      }

      sheet
          .getRangeByIndex(1, 1, totalLinhas, totalColunas + 1)
          .autoFitColumns();
    }
    // sheet.getRangeByName('A1').setText('Hello World');
    // sheet.getRangeByName('A3').setNumber(44);
    // sheet.getRangeByName('A5').setDateTime(DateTime(2020, 12, 12, 1, 10, 20));

    // Save doc.
    final List<int> bytes = workbook.saveAsStream();
    FrontUtils.downloadFile2(
        bytes,
        'Processos por Setor do Primeiro Trâmite.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    //Dispose workbook
    workbook.dispose();
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

    final labels = items.map((e) => e['nom_setor']).toList();
    final total = items.map((e) => e['total']).toList();

    if (total.isEmpty) {
      return;
    }

    final linearChartDataata =
        LinearChartData(labels: labels, datasets: <ChartDataSets>[
      ChartDataSets(
          // pointRadius: 5,
          //  borderRadius:5,
          label: 'Process por Setor Primeiro Tramite',
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
          scales: ChartScales(
              type: 'category',
              // ticks: TickOptions(),
              xAxes: [
                ChartXAxe(
                    display: true,
                    ticks: TickOptions()
                      //  ..fontSize = 4
                      ..callback2 = allowInterop((value, index, values) {
                        return FrontUtils.truncateWithEllipsis(10, '$value');
                      })),
              ]),
          //https://stackoverflow.com/questions/28296994/truncating-canvas-labels-in-chartjs-while-keeping-the-full-label-value-in-the-to
          tooltips: ChartTooltipOptions()
            ..callbacks2 = (ChartTooltipCallback2()
              ..title = allowInterop((tooltipItems, data) {
                var tooltipItem = tooltipItems[0];
                var idx = tooltipItem.index;
                var value = data.datasets[tooltipItem.datasetIndex].data[idx];
                return value;
              })
              ..label = allowInterop((tooltipItems, data) {
                var label = data.labels[tooltipItems.index];
                return label;
              })),
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
