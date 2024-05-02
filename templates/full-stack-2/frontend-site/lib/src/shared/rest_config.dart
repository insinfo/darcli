import 'dart:html' as html;

class RestConfig {
  Map<String, String> get headers => {
        'Authorization':
            'Bearer ${html.window.sessionStorage["YWNjZXNzX3Rva2VudfrtwEsic"]}',
        'Accept': 'application/json',
        'Content-type': 'application/json;charset=utf-8'
      };
  String protocol = 'http';
  String domain = 'localhost';
  int port = 3345;
  String get domainWithPort => domain + ':' + port.toString();
  String basePath = '/esicbackend/api/v1';

  RestConfig() {
    if (html.window.location.hostname?.startsWith('127.0.0.1') == true) {
      domain = 'localhost';
      port = 3345;
      protocol = 'http';
      basePath = '/esicbackend/api/v1';
    }
  }

  String get backendUrl => '$protocol://$domain:$port$basePath';

  Uri getBackendUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    /*var uri = Uri.http(domainWithPort, basePath + endpoint, queryParameters);
    if (protocol.endsWith('s')) {
      uri = Uri.https(domainWithPort, basePath + endpoint, queryParameters);
    }*/
    //var uri = Uri.parse('$backendUrl$endpoint');
    //if (queryParameters != null) {
    //uri.replace(queryParameters: queryParameters);
    //}
    var uri = Uri(
      scheme: protocol,
      host: domain,
      port: port,
      path: basePath + endpoint,
      queryParameters: queryParameters,
    );

    return uri;
  }
}
