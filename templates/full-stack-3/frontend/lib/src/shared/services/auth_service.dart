import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:sibem_frontend/sibem_frontend.dart';

class AuthService {
  String accessTokenKey = 'YWNjZXNzX3Rva2Vu';
  String message = 'Checando permissão!';
  String currentToken = '';

  Uri uriJubarte = Uri.parse(
      'https://app.site.com/api/auth/permission/check');

  AuthService() {
    final currentHost = html.window.location.hostname ?? '';
    print('AuthService currentHost $currentHost');
    print('AuthService href ${html.window.location.href}');
    if (currentHost.contains('laravel')) {
      uriJubarte = Uri.parse(
          'https://app.site.com/api/auth/permission/check');
    }
  }

  /// id de Sistema cadastrada na jubarte
  static const idSistema = 20;

  /// rota cadastrada no menu da jubarte
  String rota = '/bancoemprego';

  JubarteAuthPayload authPayload = JubarteAuthPayload.invalid();

  Future<bool> checkPermissionServer() async {
    // if (html.window.location.href.contains('http://localhost:8080')) {
    //   return true;
    // }

    try {
      final tokenData = await getToken();
      if (tokenData == null || tokenData.isEmpty) {
        return false;
      }

      final dataToSender = {
        'accessToken': tokenData,
        'idSistema': idSistema,
        'rota': rota,
        'isGetSistemasOfUser': true,
        'checkRoutePermission': false
      };
      final resp = await http.post(uriJubarte,
          body: jsonEncode(dataToSender),
          headers: {
            'Accept': 'application/json',
            'Content-type': 'application/json;charset=utf-8'
          });
      if (resp.statusCode != 200) {
        throw Exception('Não autorizado');
      } else {
        if (resp.bodyAsMap == null) {
          throw Exception('Não autorizado');
        }
        html.window.sessionStorage[accessTokenKey] = tokenData;
        authPayload = JubarteAuthPayload.fromMap(resp.bodyAsMap!);
        //print('isAdmin ${authPayload.isAdmin} ${authPayload.idUserPerfil}');
      }
      //{"authorizedAccess":true,"isUserAllowedToRoute":true,"idUserPerfil":1,"message":"Acesso Autorizado!"}
      //print('AuthService@checkToken $response');
      return true;
    } catch (e, s) {
      print('AuthService@checkToken $e $s');
      return false;
    }
  }

  Future<String?> getToken() async {
    final isInsideIframe = inIframe();
    print('getToken isInsideIframe $isInsideIframe');
    print('getToken domain ${html.window.location.href}');
    if (isInsideIframe == false) {
      return html.window.sessionStorage[accessTokenKey];
    }

    final completer = Completer<String>();
    html.window.parent!.postMessage(jsonEncode({'message': 'getToken'}), '*');
    html.window.onMessage.listen((event) {
      //print('getToken html.window.onMessage $event');
      //event.type: "message"
      String? token;
      if (event.data is String) {
        final msg = jsonDecode(event.data);
        token = msg['token'];
        currentToken = token ?? '';
        completer.complete(currentToken);
      }
    });

    return completer.future;
  }

  bool inIframe() {
    //try {
    return html.window !=
        html.window.parent; //html.window.self != html.window.top;
    // } catch (e) {
    //   return true;
    // }
  }
}
