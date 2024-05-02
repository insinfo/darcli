import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class EstatisticaController {
  static Future<dynamic> totalEncaminhadosMesAno(
      RequestContext req, ResponseContext res) async {
    try {
      final ano =
          int.tryParse(req.params['ano'].toString()) ?? DateTime.now().year;
      final mes =
          int.tryParse(req.params['mes'].toString()) ?? DateTime.now().month;
      // if (ano == null) {
      //   throw Exception('O parametro ano tem que ser um número inteiro valido');
      // }
      final repo = req.container!.make<EstatisticaRepository>();
      final data = await repo.totalEncaminhadosMesAno(ano: ano, mes: mes);
      return res.responseJsonList(data);
    } catch (e, s) {
      print('EstatisticaController@totalEncaminhadosMesAno $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> totalEmpregadorParaModerar(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EstatisticaRepository>();
      final total = await repo.totalEmpregadorParaModerar();
      return res.responseJson({'total': total});
    } catch (e, s) {
      print('EstatisticaController@totalEmpregadorParaModerar $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> totalCandidatosParaModerar(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EstatisticaRepository>();
      final total = await repo.totalCandidatosParaModerar();
      return res.responseJson({'total': total});
    } catch (e, s) {
      print('EstatisticaController@totalCandidatosParaModerar $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> totalVagasParaModerar(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EstatisticaRepository>();
      final total = await repo.totalVagasParaModerar();
      return res.responseJson({'total': total});
    } catch (e, s) {
      print('EstatisticaController@totalVagasParaModerar $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }

  static Future<dynamic> totalVagasDisponiveis(
      RequestContext req, ResponseContext res) async {
    try {
      final repo = req.container!.make<EstatisticaRepository>();
      final total = await repo.totalVagasDisponiveis();
      return res.responseJson({'total': total});
    } catch (e, s) {
      print('EstatisticaController@totalVagasDisponiveis $e $s');
      return res.responseError(StatusMessage.LIST_ERROR_MESSAGE,
          exception: e, stackTrace: s);
    }
  }
}
