

import 'package:ngdart/angular.dart';

class RoutePaths {
  /// ---------------- paginas publicas  ----------------
  static final consultaProcesso = RoutePath(path: 'consulta-processo');

  static final visualizaProcesso =
      RoutePath(path: 'visualiza-processo/:ae/:cdp');
}

String? getParam(Map<String, String> parameters, String paramName) {
  return parameters[paramName];
}
