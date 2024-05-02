// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html';

import 'package:chartjs2/chartjs.dart';
import 'package:sibem_frontend/sibem_frontend.dart';
import 'package:sibem_frontend/src/shared/utils/flatcolor.dart';

@Component(
  selector: 'encaminhamento-status-comp',
  templateUrl: 'total_encaminhamento_status_comp.html',
  styleUrls: ['total_encaminhamento_status_comp.css'],
  directives: [
    routerDirectives,
    customFormDirectives,
  ],
)
class TotalEncaminhamentoStatusComp implements OnInit {
  final EstatisticaService _estatisticaService;

  @ViewChild('canvas')
  CanvasElement? canvas;

  @ViewChild('canvasContainer')
  Element? canvasContainer;

  Element rootElement;

  TotalEncaminhamentoStatusComp(
    this._estatisticaService,
    this.rootElement,
  );

  final SimpleLoading _simpleLoading = SimpleLoading();

  List<Map<String, dynamic>> items = [];
  Filters filtros = Filters(forceRefresh: false);

  int _mes = DateTime.now().month;
  int get mes => _mes;

  set mes(int val) {
    _mes = val;
    load(true);
  }

  Future<void> load([bool preClear = false]) async {
    try {
      _simpleLoading.show(target: rootElement);
      items = await _estatisticaService.totalEncaminhadosMesAno(mes: mes);
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

  List<dynamic> get labels => items.map((e) => e['status']).toList();
  List<dynamic> get total => items.map((e) => e['total']).toList();

  void initChart([bool preClear = false]) {
    // print('ProcessosSituacaoComp@initChart $total $labels');

    if (preClear && canvas != null) {
      canvasContainer!.innerHtml = '';

      canvas = CanvasElement()
        ..width = 500
        ..height = 400;
      canvasContainer!.append(canvas!);
    }

    if (total.isEmpty) {
      return;
    }

    if(canvas == null){
      return;
    }

    var linearChartData =
        LinearChartData(labels: labels, datasets: <ChartDataSets>[
      ChartDataSets(
          // pointRadius: 5,
          //  borderRadius:5,
          label: 'Encaminhamento por status',
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

  void downloadAsPng() {
    var svgUrl = canvas!.toDataUrl('image/png');
    var downloadLink = AnchorElement(href: svgUrl);
    downloadLink.download = "grafico.png";
    downloadLink.click();
  }

  @override
  void ngOnInit() {
    //load(true);
  }
}
