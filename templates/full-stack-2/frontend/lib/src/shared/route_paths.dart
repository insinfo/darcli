import 'package:ngrouter/ngrouter.dart';

class RoutePaths {
  static final solicitante = RoutePath(path: 'solicitantes');
  static final solicitanteForm = RoutePath(path: 'solicitantes/:id'); //-detail

  static final solicitacoes = RoutePath(path: 'solicitacoes');
  static final solicitacoesForm = RoutePath(path: 'solicitacoes/:id');

  static final relatorio = RoutePath(path: 'relatorios');
  static final estatistica = RoutePath(path: 'estatisticas');

  static int? getId(Map<String, String> parameters) {
    final id = parameters['id'];
    return id == null ? null : int.tryParse(id);
  }

  static String? getParam(Map<String, String> parameters, String paramName) {
    return parameters[paramName];
  }
}
