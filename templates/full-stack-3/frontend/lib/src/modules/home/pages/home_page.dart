// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:sibem_frontend/sibem_frontend.dart';
import 'dart:html' as html;

import 'package:sibem_frontend/src/modules/estatistica/components/total_encaminhamento_status/total_encaminhamento_status_comp.dart';

@Component(
  selector: 'home-page',
  templateUrl: 'home_page.html',
  styleUrls: ['home_page.css'],
  directives: [
    coreDirectives,
    TotalEncaminhamentoStatusComp,
  ],
  providers: [],
)
class HomePage implements OnActivate {
  final EstatisticaService _estatisticaService;

  HomePage(this._estatisticaService);

  @ViewChild('cardTotalEmpregadorParaModerar')
  html.DivElement? cardTotalEmpregadorParaModerar;

  @ViewChild('cardTotalVagasParaModerar')
  html.DivElement? cardTotalVagasParaModerar;

  @ViewChild('cardTotalVagasDisponiveis')
  html.DivElement? cardTotalVagasDisponiveis;

  @ViewChild('cardTotalCandidatosParaModerar')
  html.DivElement? cardTotalCandidatosParaModerar;

  @ViewChild('encaminhamentoStatusComp')
  TotalEncaminhamentoStatusComp? encaminhamentoStatusComp;

  int totalEmpregadorParaModerar = 0;
  int totalVagasParaModerar = 0;
  int totalVagasDisponiveis = 0;
  int totalCandidatosParaModerar = 0;

  @override
  void onActivate(RouterState? previous, RouterState current) {
    loadTotalEmpregadorParaModerar();
    loadTotalVagasParaModerar();
    loadTotalVagasDisponiveis();
    loadTotalCandidatosParaModerar();

    encaminhamentoStatusComp?.load(true);
  }

  Future<void> loadTotalEmpregadorParaModerar() async {
    final load = SimpleLoading();
    try {
      load.show(target: cardTotalEmpregadorParaModerar);
      final result = await _estatisticaService.totalEmpregadorParaModerar();
      totalEmpregadorParaModerar = result['total'];
    } catch (e, s) {
      print('HomePage@loadTotalEmpregadorParaModerar $e $s');
    } finally {
      load.hide();
    }
  }

  Future<void> loadTotalCandidatosParaModerar() async {
    final load = SimpleLoading();
    try {
      load.show(target: cardTotalCandidatosParaModerar);
      final result = await _estatisticaService.totalCandidatosParaModerar();
      totalCandidatosParaModerar = result['total'];
    } catch (e, s) {
      print('HomePage@loadTotalCandidatosParaModerar $e $s');
    } finally {
      load.hide();
    }
  }

  Future<void> loadTotalVagasParaModerar() async {
    final load = SimpleLoading();
    try {
      load.show(target: cardTotalVagasParaModerar);
      final result = await _estatisticaService.totalVagasParaModerar();
      totalVagasParaModerar = result['total'];
    } catch (e, s) {
      print('HomePage@loadTotalVagasParaModerar $e $s');
    } finally {
      load.hide();
    }
  }

  Future<void> loadTotalVagasDisponiveis() async {
    final load = SimpleLoading();
    try {
      load.show(target: cardTotalVagasDisponiveis);
      final result = await _estatisticaService.totalVagasDisponiveis();
      totalVagasDisponiveis = result['total'];
    } catch (e, s) {
      print('HomePage@loadTotalVagasDisponiveis $e $s');
    } finally {
      load.hide();
    }
  }
}
