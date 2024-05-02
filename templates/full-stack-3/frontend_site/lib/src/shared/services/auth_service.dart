import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:http/http.dart' as http;
import 'package:sibem_frontend_site/sibem_frontend_site.dart';

enum LoginStatus { logged, notLogged, checking, none }

class AuthService {
  final RestConfig restConfig;

  AuthService(this.restConfig);

  static const String accessTokenKey = 'YWNjZXNzX3Rva2VudfrtwSibem';
  static const String _authPayloadKey = 'asd54dg5dfsdgf5sdfgd56srSibem';
  static const String _expiresInKey = '_expiresInKeySibem';
  static const String _inicioSessionKey = '_inicioSessionKeySibem';

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

  AuthPayload authPayload = AuthPayload.invalid();

  String accessToken = '';

  LoginStatus loginStatus = LoginStatus.none;
  String sessionTimeOut = '00:00:00';
  late DateTime timeInicioSession;
  late DateTime timeLastBrowserTabOut;
  //late Timer _timer;

  void setLastBrowserTabOut() {
    timeLastBrowserTabOut = DateTime.now();
  }

  void isNessesarioFazerLogout() {
    // print('isNessesarioFazerLogout ${DateTime.now().difference(timeInicioSession).inSeconds}');
    if (DateTime.now().difference(timeInicioSession).inHours > 9) {
      doLogout();
      var a = AreaElement();
      document.body!.append(a);
      a.click();
      a.remove();
      //print('faz logout');
    }
  }

  /// checa se o usuario esta logado de fato
  Future<bool> isLoggedIn({bool updateOnLogout = true}) async {
    print('isLoggedIn loginStatus ${loginStatus}');
    if (loginStatus == LoginStatus.logged) {
      final now = DateTime.now();
      if (now.isAfter(authPayload.expiry)) {
        print('AuthService@isLoggedIn token expirou ');
        loginStatus = LoginStatus.notLogged;
        if (updateOnLogout) {
          onLogoutStreamController.add(loginStatus);
        }
        return false;
      }
      return true;
    } else if (loginStatus == LoginStatus.checking) {
      final isLoged = await aguardeCheckToken();
      return isLoged;
    }

    return await checkToken(updateOnLogout: updateOnLogout);
  }

  Future<bool> aguardeCheckToken() async {
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 20));
      if (loginStatus != LoginStatus.checking) {
        return false;
      }
      return true;
    }).timeout(Duration(seconds: 5));
    if (loginStatus == LoginStatus.logged) {
      return true;
    }
    return false;
  }

  void _fillSessionStorage() {
    window.sessionStorage[accessTokenKey] = accessToken;
    window.sessionStorage[_authPayloadKey] = authPayload.toJson();
    window.sessionStorage[_expiresInKey] = authPayload.expiry.toString();
    //_inicioSessionKey
  }

  void _clearSessionStorage() {
    window.sessionStorage.remove(accessTokenKey);
    window.sessionStorage.remove(_authPayloadKey);
    window.sessionStorage.remove(_expiresInKey);
    authPayload = AuthPayload.invalid();
  }

  void _getAuthPayloadFromSessionStorage() {
    accessToken = window.sessionStorage[accessTokenKey] ?? '';
    if (window.sessionStorage[_authPayloadKey] != null) {
      authPayload =
          AuthPayload.fromJson(window.sessionStorage[_authPayloadKey]!);
    }

    //pega a hora que inicio a seção (hora do login)
    if (window.sessionStorage.containsKey(_inicioSessionKey)) {
      timeInicioSession =
          DateTime.parse(window.sessionStorage[_inicioSessionKey].toString());
    }
  }

  void doLogout() {
    loginStatus = LoginStatus.notLogged;
    onLogoutStreamController.add(loginStatus);
    _clearSessionStorage();
  }

  void initPostAuth() {
    print('AuthService@initPostAuth');
    _getAuthPayloadFromSessionStorage();

    //exibe e inicializa o timeout da Sessão
    if (window.sessionStorage[_expiresInKey] != null) {
      Timer.periodic(const Duration(seconds: 2), (timer) {
        if (loginStatus == LoginStatus.notLogged) {
          timer.cancel();
        }
        // print('Timer.periodic ${window.sessionStorage[_expiresInKey]}');
        if (!(window.sessionStorage[_expiresInKey] is String)) {
          return;
        }
        //32400 segundo = 9 horas
        final expiresIn =
            DateTime.parse(window.sessionStorage[_expiresInKey] as String);

        var d = expiresIn.difference(DateTime.now());
        sessionTimeOut =
            '${FrontUtils.addZero(d.inHours)}:${FrontUtils.addZero(d.inMinutes.remainder(60))}:${FrontUtils.addZero(d.inSeconds.remainder(60))}';

        document.querySelector('#authServiceSessionTimeOut')?.text =
            sessionTimeOut;
        var timeCount = d.inSeconds;

        if (timeCount <= 0) {
          timer.cancel();
          doLogout();
        }
      });
    }
  }

  Future<void> trocaSenha(
      String login, String senhaAtual, String novaSenha) async {
    final client = http.Client();
    final url = Uri.parse('${restConfig.backendUrl}/auth/change/pass');
    final resp = await client.post(url,
        body: jsonEncode({
          'login': login,
          'senhaAtual': senhaAtual,
          'novaSenha': novaSenha,
        }),
        headers: restConfig.headers);

    if (resp.statusCode != 200) {
      throw Exception(' ${resp.bodyUtf8}');
    }
  }

  Future<UsuarioWeb> resetaSenha(String login) async {
    final url = Uri.parse('${restConfig.backendUrl}/auth/reset/pass');
    final resp = await http.post(url,
        body: jsonEncode({'login': login}), headers: restConfig.headers);
    if (resp.statusCode == 200) {
      return UsuarioWeb.fromMap(jsonDecode(resp.bodyUtf8));
    } else {
      throw Exception(resp.bodyUtf8);
    }
  }

  /// toda vez que o usuario da reloud na pagina faz uma nova checagem pra verificar se o usuario tem acesso
  /// ou seja verifica se esta logado
  Future<bool> checkToken({bool updateOnLogout = true}) async {
    print('checkToken ${loginStatus}');
    loginStatus = LoginStatus.checking;
    final simpleLoading = SimpleLoading();
    try {
      final tokenData = window.sessionStorage[accessTokenKey];
      if (tokenData == null || tokenData.isEmpty) {
        loginStatus = LoginStatus.notLogged;
        if (updateOnLogout) {
          onLogoutStreamController.add(loginStatus);
        }
        return false;
      }

      final url = Uri.parse('${restConfig.backendUrl}/auth/check');
      //'.content-wrapper'
      simpleLoading.showHorizontal2(target: document.querySelector('body'));
      final resp = await http.post(url,
          body: jsonEncode({'accessToken': tokenData}),
          headers: restConfig.headers);

      if (resp.statusCode == 200) {
        if (loginStatus != LoginStatus.logged) {
          loginStatus = LoginStatus.logged;
        }
        final data = jsonDecode(resp.bodyUtf8);
        authPayload.expiry = DateTime.parse(data['expiry']);

        initPostAuth();
        onCheckPermissionStreamController.add(loginStatus);
        return true;
      } else if (resp.statusCode == 401) {
        throw UnauthorizedOrSessionExpiredException();
      } else if (resp.statusCode == 403) {
        throw UnauthorizedException();
      } else if (resp.statusCode == 440) {
        window.sessionStorage.remove(accessTokenKey);
        throw SessionExpiredException();
      } else {
        throw Exception(resp.bodyUtf8);
      }
    } catch (e, s) {
      print('AuthService@checkToken $e $s');
      loginStatus = LoginStatus.notLogged;
      if (updateOnLogout) {
        onLogoutStreamController.add(loginStatus);
      }
    } finally {
      simpleLoading.hide();
    }
    return false;
  }

  //faz o login
  Future<bool> doLogin(LoginPayload loginPayload) async {
    var result = false;
    try {
      loginStatus = LoginStatus.checking;
      var url = Uri.parse('${restConfig.backendUrl}/auth/login');
      var response = await http.post(
        url,
        headers: restConfig.headers,
        body: jsonEncode(loginPayload.toMap()),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.bodyUtf8) as Map<String, dynamic>;
        accessToken = data['accessToken'];
        authPayload = AuthPayload.fromMap(data);
        _fillSessionStorage();
        timeInicioSession = DateTime.now();
        window.sessionStorage[_inicioSessionKey] =
            timeInicioSession.toIso8601String();

        initPostAuth();
        loginStatus = LoginStatus.logged;
        onLoginStreamController.add(loginStatus);
        result = true;
        return result;
      } else if (response.statusCode == 404) {
        throw UserNotFoundException();
      } else if (response.statusCode == 403) {
        throw UserNotActivatedException();
      } else if (response.statusCode == 401) {
        var restEr = RestError.fromJson(response.bodyUtf8);
        throw Exception(restEr.exception);
      } else {
        throw Exception(response.bodyUtf8);
      }
    } catch (e) {
      rethrow;
    }
  }
}
