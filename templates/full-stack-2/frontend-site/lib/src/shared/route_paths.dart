import 'package:ngrouter/ngrouter.dart';

class RoutePaths {
  static final bemVindo = RoutePath(path: 'bem-vindo', parent: restrito);
  static final listaSolicitacao =
      RoutePath(path: 'lista-solicitacao', parent: restrito);
  static final criaSolicitacao =
      RoutePath(path: 'cria-solicitacao', parent: restrito);
  static final detalheSolicitacao =
      RoutePath(path: 'detalhe-solicitacao/:id', parent: restrito);

  static final alterarSenha =
      RoutePath(path: 'alterar-senha', parent: restrito);

  //----------------- PUBLIC ROUTES

  static final restrito = RoutePath(path: 'restrito');
  static final legislacao = RoutePath(path: 'legislacao');
  static final login = RoutePath(path: 'login');
  static final home = RoutePath(path: 'home');
  static final recuperarAcesso = RoutePath(path: 'recuperar-acesso');
  static final cadastroSolicitante =
      RoutePath(path: 'cadastro-solicitante/:id');
  static final estatisticaSolicitacao =
      RoutePath(path: 'estatistica-solicitacao');

  // static final parameterCadastro = {'id': 'new'};

  static final cadastroSolicitanteUrl =
      cadastroSolicitante.toUrl(parameters: {'id': 'new'});

  static int? getId(Map<String, String> parameters) {
    final id = parameters['id'];
    return id == null ? null : int.tryParse(id);
  }

  static String? getParam(Map<String, String> parameters, String paramName) {
    return parameters[paramName];
  }
}
