import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:esic_frontend_site/src/shared/rest_config.dart';
import 'package:esic_core/esic_core.dart';
import 'package:http/http.dart' as http;
import '../extensions/http_response_extension.dart';

enum LoginStatus { logged, notLogged, checking }

class AuthService {
  final String _accessTokenKey = 'YWNjZXNzX3Rva2VudfrtwEsic';
  final String _cpfPessoaKey = 'cpfPessoaEsic';
  final String _idPessoaKey = 'idPessoaEsic';
  final String _idSistemaKey = 'idSistemaEsic';
  final String _loginNameKey = 'loginNameEsic';

  String accessToken = '';
  String cpfPessoa = '';
  int idPessoa = -1;
  int idSistema = -1;
  String loginName = '';

  LoginStatus loginStatus = LoginStatus.checking;

  StreamController<LoginStatus> onLogoutStreamController =
      StreamController<LoginStatus>.broadcast();
  Stream<LoginStatus> get onLogout => onLogoutStreamController.stream;

  StreamController<LoginStatus> onLoginStreamController =
      StreamController<LoginStatus>.broadcast();

  Stream<LoginStatus> get onLogin =>
      onLoginStreamController.stream; //.asBroadcastStream();

  StreamController<LoginStatus> onCheckPermissionStreamController =
      StreamController<LoginStatus>.broadcast();

  Stream<LoginStatus> get onCheckPermission =>
      onCheckPermissionStreamController.stream;

  final RestConfig restConfig;

  AuthService(this.restConfig);

  void _fillSessionStorage() {
    window.sessionStorage[_accessTokenKey] = accessToken;
    window.sessionStorage[_cpfPessoaKey] = cpfPessoa;
    window.sessionStorage[_idPessoaKey] = idPessoa.toString();
    window.sessionStorage[_idSistemaKey] = idSistema.toString();
    window.sessionStorage[_loginNameKey] = loginName;
  }

  void _clearSessionStorage() {
    window.sessionStorage.remove(_accessTokenKey);
    window.sessionStorage.remove(_cpfPessoaKey);
    window.sessionStorage.remove(_idPessoaKey);
    window.sessionStorage.remove(_idSistemaKey);
    window.sessionStorage.remove(_loginNameKey);
  }

  void _getAuthPayloadFromSessionStorage() {
    accessToken = window.sessionStorage[_accessTokenKey]!;
    cpfPessoa = window.sessionStorage[_cpfPessoaKey]!;
    idPessoa = int.parse(window.sessionStorage[_idPessoaKey]!);
    idSistema = int.parse(window.sessionStorage[_idSistemaKey]!);
    loginName = window.sessionStorage[_loginNameKey]!;
  }

  void doLogout() {
    loginStatus = LoginStatus.notLogged;
    onLogoutStreamController.add(loginStatus);
    _clearSessionStorage();
  }

  void initPostAuth() {}

  Future<Solicitante> resetaSenha(String cpfcnpj) async {
    final client = http.Client();
    final url = Uri.parse('${restConfig.backendUrl}/reset/pass');
    final resp = await client.post(url,
        body: jsonEncode({'cpfcnpj': cpfcnpj}), headers: restConfig.headers);
    if (resp.statusCode == 200) {
      return Solicitante.fromMap(jsonDecode(resp.bodyUtf8));
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  Future<Solicitante> trocaSenha(
      String cpfcnpj, String senhaAtual, String novaAtual) async {
    final client = http.Client();
    final url = Uri.parse('${restConfig.backendUrl}/change/pass');
    final resp = await client.post(url,
        body: jsonEncode({
          'cpfcnpj': cpfcnpj,
          'senhaAtual': senhaAtual,
          'novaAtual': novaAtual,
        }),
        headers: restConfig.headers);
    if (resp.statusCode == 200) {
      return Solicitante.fromMap(jsonDecode(resp.bodyUtf8));
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  /// toda vez que o usuario da reloud na pagina faz uma nova checagem pra verificar se o usuario tem acesso
  /// ou seja verifica se esta logado
  Future<bool> checkPermissionServer() async {
    var client = http.Client();

    try {
      //loginStatus = LoginStatus.checking;
      var url = Uri.parse('${restConfig.backendUrl}/auth/site/check');
      var tokenData = window.sessionStorage[_accessTokenKey];
      if (tokenData == null || tokenData.isEmpty) {
        loginStatus = LoginStatus.notLogged;
        onLogoutStreamController.add(loginStatus);
      } else {
        var resp = await client.post(url,
            body: jsonEncode({'accessToken': tokenData}),
            headers: restConfig.headers);
        if (resp.statusCode == 200) {
          //var json = jsonDecode(resp.body);
          //print(json);
          if (loginStatus != LoginStatus.logged) {
            loginStatus = LoginStatus.logged;
          }
          initPostAuth();
          _getAuthPayloadFromSessionStorage();
          onCheckPermissionStreamController.add(loginStatus);
          return true;
        } else if (resp.statusCode == 401) {
          throw UnauthorizedOrSessionExpiredException();
        } else if (resp.statusCode == 403) {
          throw UnauthorizedException();
        } else if (resp.statusCode == 440) {
          throw SessionExpiredException();
        } else {
          throw Exception(resp.bodyUtf8);
        }
      }
    } catch (e, s) {
      print('AuthService@checkToken $e $s');
      loginStatus = LoginStatus.notLogged;
      onLogoutStreamController.add(loginStatus);
      return false;
    }
    return false;
  }

  //faz o login
  Future<void> doLogin(LoginPayload loginPayload) async {
    var client = http.Client();

    try {
      loginStatus = LoginStatus.checking;
      var url = Uri.parse('${restConfig.backendUrl}/auth/site/login');
      var response = await client.post(
        url,
        headers: restConfig.headers,
        body: jsonEncode(loginPayload.toMap()),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.bodyUtf8) as Map<String, dynamic>;
        accessToken = data['accessToken'];
        cpfPessoa = data['cpfPessoa'];
        idPessoa = data['idPessoa'];
        idSistema = data['idSistema'];
        loginName = data['loginName'];
        // authPayload = AuthPayload.fromMap(data);
        _fillSessionStorage();
        initPostAuth();
        loginStatus = LoginStatus.logged;
        onLoginStreamController.add(loginStatus);
      } else if (response.statusCode == 403) {
        throw UserNotActivatedException();
      } else {
        throw Exception('${jsonDecode(response.bodyUtf8)['message']}');
      }
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }
}
