import 'package:sibem_frontend/sibem_frontend.dart';
import 'dart:html';
import 'package:chartjs2/chartjs.dart';
import 'package:sibem_frontend/src/shared/utils/flatcolor.dart';

@Component(
  selector: 'total-encaminhados-comp',
  templateUrl: 'total_encaminhados.html',
  directives: [
    coreDirectives,
  ],
)
class TotalEncaminhadosComp {
  // ignore: unused_field
  final EstatisticaService _estatisticaService;

  @ViewChild('canvas')
  CanvasElement? canvas;

  @ViewChild('canvasContainer')
  Element? canvasContainer;

  Element rootElement;

  TotalEncaminhadosComp(this._estatisticaService, this.rootElement);

  var items = <Map<String, dynamic>>[];
  Filters filtros = Filters(limit: 1, forceRefresh: false);

  Future<void> load([bool preClear = false]) async {
    final loading = SimpleLoading();
    try {
      loading.show(target: rootElement);
      // items = await _estatisticaService.totalAmbulantesPorDia(filtros);

      initGrafico(preClear);
    } catch (e, s) {
      print('TotalEncaminhadosComp@load $e $s');
    } finally {
      loading.hide();
    }
  }

  void atualizar() {
    filtros.forceRefresh = true;
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

    final labels = items.map((e) => e['day']).toList();
    final total = items.map((e) => e['total']).toList();

    if (total.isEmpty) {
      return;
    }

    final linearChartDataata =
        LinearChartData(labels: labels, datasets: <ChartDataSets>[
      ChartDataSets(
          // pointRadius: 5,
          //  borderRadius:5,
          label: 'processos por dia',
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
    final svgUrl = canvas!.toDataUrl('image/png');
    final downloadLink = AnchorElement(href: svgUrl);
    downloadLink.download = "grafico.png";
    downloadLink.click();
  }
}
