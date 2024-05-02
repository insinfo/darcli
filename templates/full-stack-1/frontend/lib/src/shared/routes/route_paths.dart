import 'package:new_sali_frontend/new_sali_frontend.dart';

class RoutePaths {
  /// ---------------- paginas publicas  ----------------
  static final login = RoutePath(path: 'login');
  static final sessionExpired = RoutePath(path: 'sessao-expirou');

  /// ---------------- paginas restritas  ----------------
  static final restrito = RoutePath(path: 'restrito');

  static final home = RoutePath(path: 'home', parent: restrito);
 
  static final sobre = RoutePath(path: 'sobre', parent: restrito);

  // modulo auth
  static final alterarSenha =
      RoutePath(path: 'alterar-senha', parent: restrito);

  static final notImplemented =
      RoutePath(path: 'nao-implementado', parent: restrito);

  static RoutePath mapRotaToAcao(int acao) {
    switch (acao) {
      case 24:
        return alterarSenha;

      default:
        return notImplemented;
    }
  }

  static final unauthorized = RoutePath(path: 'unauthorized');
  static final unauthorizedPrivate =
      RoutePath(path: 'unauthorized', parent: restrito);
  static final notFoundPrivate = RoutePath(path: 'not-found', parent: restrito);
}

int? getId(Map<String, String> parameters) {
  final id = parameters['id'];
  return id == null ? null : int.tryParse(id);
}

String? getParam(Map<String, String> parameters, String paramName) {
  return parameters[paramName];
}
