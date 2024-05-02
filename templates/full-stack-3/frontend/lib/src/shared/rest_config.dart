import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

class RestConfig {
  Map<String, String> get headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-type': 'application/json;charset=utf-8'
      };
  String protocol = 'http';
  String domain = 'localhost';
  int port = 3328;
  String get domainWithPort => '$domain:$port';
  String basePath = '/api/v1';

  // Lazily inject `Router` to avoid cyclic dependency.
  final Injector _injector;
  Router? _router;
  // Lazily inject `Router` to avoid cyclic dependency.
  Router get router => _router ??= _injector.provideType(Router);


  RestConfig(this._injector) {
    final currentProto = html.window.location.protocol
        .substring(0, html.window.location.protocol.length - 1);
    final currentHost = html.window.location.hostname ?? '';

    var currentPort = int.tryParse(html.window.location.port);
    currentPort = currentPort == null && currentProto == 'https' ? 443 : 80;

    print(
        'RestConfig Proto $currentProto Host $currentHost Port $currentPort location.port ${html.window.location.port} protocol ${html.window.location.protocol}');

     if (currentHost.startsWith('192.168.66.123')) {
      domain = '192.168.66.123';
      port = 3328;
    }
  }

  String get backendUrl => '$protocol://$domain:$port$basePath';

  String get token => html.window.sessionStorage["YWNjZXNzX3Rva2Vu"] ?? '';

  /// retorna a url do backend
  /// [withBasePath] se true traz o base path da API
  Uri getBackendUri(String endpoint,
      {Map<String, dynamic>? queryParameters,
      bool withBasePath = true,
      bool withToken = false}) {
    final qp = queryParameters ?? <String, dynamic>{};

    final tok = withToken ? {'t': token} : <String, dynamic>{};

    final path = withBasePath ? basePath + endpoint : endpoint;
    final uri = Uri(
      scheme: protocol,
      host: domain,
      port: port,
      path: path,
      queryParameters: {...qp, ...tok},
    );

    return uri;
  }
}
