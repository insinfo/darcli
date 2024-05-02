import 'dart:html' as html;

import 'package:ngdart/angular.dart';


class RestConfig {
  Map<String, String> get headers => {
        'Authorization':
            'Bearer ${html.window.sessionStorage["YWNjZXNzX3Rva2VudfrtwSali"]}',
        'Accept': 'application/json',
        'Content-type': 'application/json;charset=utf-8'
      };
  String protocol = 'http';
  String domain = 'localhost';
  int port = 3350;
  String get domainWithPort => domain + ':' + port.toString();
  String basePath = '/api/v1';

  // Lazily inject `Router` to avoid cyclic dependency.
  final Injector _injector;
  Router? _router;
  // Lazily inject `Router` to avoid cyclic dependency.
  Router get router => _router ??= _injector.provideType(Router);

  RestConfig(this._injector) {
    //print('RestConfig hostname: ${html.window.location.hostname} protocol: ${html.window.location.protocol}');
   if (html.window.location.hostname?.startsWith('app.') == true &&
        html.window.location.protocol.contains('http')) {
      domain = 'app.site.com';
      port = 80;
      protocol = 'http';
      basePath = '/salibackend/api/v1';
    } //para minha maquina teste
    else if (html.window.location.hostname?.startsWith('192.168.66.123') ==
            true &&
        html.window.location.protocol.contains('http')) {
      domain = '192.168.66.123';
      port = 3350;
      protocol = 'http';
      basePath = '/api/v1';
    }
  }

  String get backendUrl => '$protocol://$domain:$port$basePath';

  /// retorna a url do backend
  /// [withBasePath] se true traz o base path da API
  Uri getBackendUri(String endpoint,
      {Map<String, dynamic>? queryParameters, bool withBasePath = true}) {
    /*var uri = Uri.http(domainWithPort, basePath + endpoint, queryParameters);
    if (protocol.endsWith('s')) {
      uri = Uri.https(domainWithPort, basePath + endpoint, queryParameters);
    }*/
    //var uri = Uri.parse('$backendUrl$endpoint');
    //if (queryParameters != null) {
    //uri.replace(queryParameters: queryParameters);
    //}
    final path = withBasePath ? basePath + endpoint : endpoint;
    final uri = Uri(
      scheme: protocol,
      host: domain,
      port: port,
      path: path,
      queryParameters: queryParameters,
    );

    return uri;
  }
}
