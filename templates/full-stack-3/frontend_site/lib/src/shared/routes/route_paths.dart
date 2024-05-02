import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class RoutePaths {
  /// ---------------- paginas publicas  ----------------
  static final login = RoutePath(path: 'login');
  static final cadastrarUsuario = RoutePath(path: 'cadastrar');
  static final recuperarAcesso = RoutePath(path: 'recuperar-acesso');
  static final restrito = RoutePath(path: 'restrito');
  static final listaVaga = RoutePath(path: 'vagas');

  /// ---------------- paginas restritas  ----------------
  static final bemVindo = RoutePath(path: 'bem-vindo', parent: restrito);
  static final formCandidatoWeb =
      RoutePath(path: 'pre-cadastro', parent: restrito);
  static final formEmpregadorWeb =
      RoutePath(path: 'pre-cadastro-empregador', parent: restrito);
  static final formVaga = RoutePath(path: 'vagas/:id', parent: restrito);
  static final alterarSenha =
      RoutePath(path: 'alterar-senha', parent: restrito);

  static final sessionExpired = RoutePath(path: 'sessao-expirou');
  static final unauthorizedPrivate = RoutePath(path: 'unauthorized-private');
  static final unauthorized = RoutePath(path: 'unauthorized-public');

  static final listaCandidatoEncaminhado = RoutePath(path: 'candidatos-encaminhados', parent: restrito);

  static int? getId(Map<String, String> parameters) {
    final id = parameters['id'];
    return id == null ? null : int.tryParse(id);
  }
}

String? getParam(Map<String, String> parameters, String paramName) {
  return parameters[paramName];
}
