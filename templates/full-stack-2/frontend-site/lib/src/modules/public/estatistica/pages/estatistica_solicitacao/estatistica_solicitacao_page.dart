import 'dart:html';

import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend_site/src/modules/public/estatistica/services/estatistica_service.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/angular_router.dart';
import 'package:chartjs/chartjs.dart';

@Component(
  selector: 'estatistica-solicitacao-page',
  templateUrl: 'estatistica_solicitacao_page.html',
  styleUrls: ['estatistica_solicitacao_page.css'],
  directives: [
    coreDirectives,
  ],
  providers: [
    ClassProvider(EstatisticaService),
  ],
)
class EstatisticaSolicitacaoPage implements OnActivate {
  final EstatisticaService _estatisticaService;

  @ViewChild('containerGrafico')
  DivElement? containerGrafico;

  EstatisticaSolicitacaoPage(this._estatisticaService);

  Filters filtros = Filters(limit: null, offset: null, orderDir: null);

  DataFrame<EstatisticaSolicitacao> estatisticaSolicitacao =
      DataFrame<EstatisticaSolicitacao>(items: [], totalRecords: 0);

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await solicitacoesPorAno();
    loadGrafico();
  }

  Future<void> solicitacoesPorAno() async {
    estatisticaSolicitacao =
        await _estatisticaService.solicitacoesPorAno(filtros);
  }

  void loadGrafico() {
    containerGrafico?.innerHtml = '';

    final labels = estatisticaSolicitacao.items.map((m) => m.ano).toList();
    final totais =
        estatisticaSolicitacao.items.map<int>((m) => m.total).toList();
    final respondidas =
        estatisticaSolicitacao.items.map((m) => m.respondidas).toList();

    final data = LinearChartData(labels: labels, datasets: <ChartDataSets>[
      ChartDataSets(
        label: 'Pedidos Registrados',
        backgroundColor: '#006699', //'#ff6384', //'rgba(54,162,235,1)',
        data: totais,
        // borderColor: 'rgba(20,20,255,0.5)',
        //borderWidth: 1,
        // hoverBackgroundColor: 'rgba(20,20,255,0.9)',
        //hoverBorderColor: 'navy',
        // lineTension: 0.00001,
        //pointRadius: 5,
      ),
      ChartDataSets(
          label: 'Pedidos Atendidos',
          backgroundColor: '#FF9900', //'#36a2eb',
          data: respondidas),
    ]);
    final tickOptions = TickOptions();
    tickOptions.fontSize = 7;

    final config = ChartConfiguration(
      type: 'bar',
      data: data,
      options: ChartOptions(
        // scales: LinearScale(xAxes: [ChartXAxe(ticks: tickOptions)]),
        //  elements: ChartElementsOptions(),
        //scales: ChartScales(position: 'y'),
        responsive: true,
        title: ChartTitleOptions(
          //fontSize: 3,
          display: false,
        ),
      ),
    );

    var canvas = CanvasElement();
    containerGrafico?.append(canvas);
    Chart(canvas, config);
  }
}
