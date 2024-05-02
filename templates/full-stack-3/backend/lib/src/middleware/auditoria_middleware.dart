import 'dart:async';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:sibem_backend/sibem_backend.dart';

class AuditoriaMiddleware {
  static List<String> _metodosAuditados = ['POST', 'PUT', 'DELETE', 'PATCH'];
  static List<String> _pathNaoAuditados = ['/auditoria', '/auth/'];

  bool _stringContainsOneOf(String input, List<String> list) {
    for (String listItem in list) {
      if (input.contains(listItem)) {
        return true;
      }
    }
    return false;
  }

  String _getAcaoFromUrl(
      String path, String method, Map<String, dynamic> params) {
    final p = path;
    var entidade = p;
    if (params.isNotEmpty) {
      if (p.contains('/')) {
        final parts = p.split('/');
        entidade =
            parts[parts.length > 2 ? parts.length - 2 : parts.length - 1];
      }
    } else {
      if (p.contains('/')) {
        final parts = p.split('/');
        entidade = parts.last;
      }
    }

    switch (method) {
      case 'DELETE':
        return 'Remoção $entidade';
      case 'POST':
        return 'Cadastro $entidade';
      case 'PUT':
        return 'Atualização $entidade';
      case 'PATCH':
        return 'Atualização parcial $entidade';
      default:
        return '';
    }
  }

  Future handleRequest(RequestContext req, ResponseContext res) async {
    print('AuditoriaMiddleware ${req.method} ${req.path}');

    if (_metodosAuditados.contains(req.method) &&
        _stringContainsOneOf(req.path, _pathNaoAuditados) == false) {
      final repo = req.container!.make<AuditoriaRepository>();

      final auditoria = Auditoria(
        data: DateTime.now(),
        acao: _getAcaoFromUrl(req.path, req.method, req.params),
        id: -1,
        usuarioId: req.jubarteToken.idPessoa,
        usuarioNome: req.jubarteToken.loginName,
        metodo: req.method,
        path: req.path,
        //req.method == 'DELETE' && req.params.values.isEmpty ? req.bodyAsList :
        objeto: req.params.values.join(','),
      );

      repo.create(auditoria);
    }
    return true;
  }

  /// Middleware para uso com o roteador customizado
   Future Function(RequestContext req, ResponseContext res) handle(
      innerHandler) {
    return (RequestContext req, ResponseContext res) async {
      print('AuditoriaMiddleware ${req.method} ${req.path}');

    if (_metodosAuditados.contains(req.method) &&
        _stringContainsOneOf(req.path, _pathNaoAuditados) == false) {
      final repo = req.container!.make<AuditoriaRepository>();

      final auditoria = Auditoria(
        data: DateTime.now(),
        acao: _getAcaoFromUrl(req.path, req.method, req.params),
        id: -1,
        usuarioId: req.jubarteToken.idPessoa,
        usuarioNome: req.jubarteToken.loginName,
        metodo: req.method,
        path: req.path,
        //req.method == 'DELETE' && req.params.values.isEmpty ? req.bodyAsList :
        objeto: req.params.values.join(','),
      );

      repo.create(auditoria);
    }
    };
  }
}
