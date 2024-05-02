import 'dart:convert';
import 'dart:html';

import 'package:esic_core/esic_core.dart';
import 'package:http/http.dart' as http;
import '../extensions/http_response_extension.dart';

class AuthService {
  AuthService();
  String accessTokenKey = 'YWNjZXNzX3Rva2Vu';
  String message = 'Checando permissão!';
  int? _idSecretaria =
      int.tryParse(window.sessionStorage['idSecretaria'].toString());

  int getIdPessoa() {
    return int.parse(window.sessionStorage['idPessoa'].toString());
  }

  int? getIdSecretaria() {
    return _idSecretaria;
  }

  Future<bool> checkPermissionServer() async {
    var url =
        'https://app.site.com/api/auth/permission/check';
    var idSistema = 17; //id sistema
    var rota = '/bluefin'; //rota cadastrada no menu 
    try {
      var tokenData = window.sessionStorage[accessTokenKey];
      if (tokenData == null || tokenData.isEmpty) {
        return false;
      }

      var dataToSender = {
        'accessToken': window.sessionStorage[accessTokenKey].toString(),
        'idSistema': idSistema,
        'rota': rota,
        'isGetSistemasOfUser': true,
        'checkRoutePermission': true
      };
      var resp = await http.post(Uri.parse(url),
          body: jsonEncode(dataToSender),
          headers: {
            'Accept': 'application/json',
            'Content-type': 'application/json;charset=utf-8'
          });
      if (resp.statusCode == 200) {
        var data = jsonDecode(resp.bodyUtf8);
        if (data is Map && data.containsKey('sistemasOfUser')) {
          var sistemasOfUser = data['sistemasOfUser'];
          if (sistemasOfUser is List) {
            sistemasOfUser.forEach((item) {
              if (item['idSistema'] == ID_SISTEMA_ESIC) {
                _idSecretaria = item['idSecretaria'];
              }
            });
          }
        }
      } else {
        throw Exception('Não autorizado');
      }
      //{"authorizedAccess":true,"isUserAllowedToRoute":true,"idUserPerfil":1,"message":"Acesso Autorizado!"}
      //print('AuthService@checkToken $response');
      return true;
    } catch (e, s) {
      print('AuthService@checkToken $e $s');
      return false;
    }
  }
}
