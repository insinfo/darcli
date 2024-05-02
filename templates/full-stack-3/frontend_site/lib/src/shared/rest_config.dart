import 'dart:html' as html;
import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class RestConfig {
  Map<String, String> get headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-type': 'application/json;charset=utf-8'
      };
  String protocol = 'http';
  String domain = 'localhost';
  //3327
  int port = 3328;
  String get domainWithPort => '$domain:$port';
  String basePath = '/web/api/v1';

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

    if (currentHost.startsWith('newsibem') == true) {
      domain = 'app.site.com';
      port = currentPort;
      protocol = currentProto;
      basePath = '/sibemserver/web/api/v1';
    } 
    else if (currentHost.startsWith('192.168.66.123')) {
      domain = '192.168.66.123';
      port = 3328;
    }
  }

  String get backendUrl => '$protocol://$domain:$port$basePath';

  String get token =>
      html.window.sessionStorage[AuthService.accessTokenKey] ?? '';

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
