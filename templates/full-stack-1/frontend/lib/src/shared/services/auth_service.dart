import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:new_sali_core/new_sali_core.dart';
import 'package:http/http.dart' as http;
import 'package:new_sali_frontend/new_sali_frontend.dart';

enum LoginStatus { logged, notLogged, checking }

class AuthService {
  final String _accessTokenKey = 'YWNjZXNzX3Rva2VudfrtwSali';
  final String _authPayloadKey = 'asd54dg5dfsdgf5sdfgd56srSali';
  final String _expiresInKey = '_expiresInKey';
  final String _inicioSessionKey = '_inicioSessionKey';

  List<MenuItem> menus = [];

  AuthPayload authPayload = AuthPayload(
    anoExercicio: '',
    codDepartamento: -1,
    codOrgao: -1,
    codSetor: -1,
    idSetor: -1,
    codUnidade: -1,
    nomCgm: '',
    nomSetor: '',
    numCgm: -1,
    username: '',
    expiry: DateTime.now().add(Duration(hours: 1)),
    anoExercicioSetor: '',
  );

  String accessToken = '';

  LoginStatus loginStatus = LoginStatus.checking;
  String sessionTimeOut = '00:00:00';
  late DateTime timeInicioSession;
  late DateTime timeLastBrowserTabOut;
  late Timer _timer;

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
  Future<bool> isLoggedIn() async {
    if (loginStatus == LoginStatus.logged) {
      final now = DateTime.now();
      if (now.isAfter(authPayload.expiry)) {
        print('AuthService@isLoggedIn token expirou ');
        loginStatus = LoginStatus.notLogged;
        onLogoutStreamController.add(loginStatus);
        return false;
      }
      return true;
    }
    return checkToken();
  }

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

  AuthService(this.restConfig) {
    _getAuthPayloadFromSessionStorage();
  }

  void _fillSessionStorage() {
    window.sessionStorage[_accessTokenKey] = accessToken;
    window.sessionStorage[_authPayloadKey] = authPayload.toJson();
    window.sessionStorage[_expiresInKey] = authPayload.expiry.toString();
    //_inicioSessionKey
  }

  void _clearSessionStorage() {
    window.sessionStorage.remove(_accessTokenKey);
    window.sessionStorage.remove(_authPayloadKey);
    window.sessionStorage.remove(_expiresInKey);
    //_inicioSessionKey
  }

  void _getAuthPayloadFromSessionStorage() {
    accessToken = window.sessionStorage[_accessTokenKey] ?? '';
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
    _timer.cancel();
    _clearSessionStorage();
  }

  void initPostAuth() {
    //print('initPostAuth');
    _getAuthPayloadFromSessionStorage();

    //exibe e inicializa o timeout da Sessão
    if (window.sessionStorage[_expiresInKey] != null) {
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        //32400 segundo = 9 horas
        final expiresIn =
            DateTime.parse(window.sessionStorage[_expiresInKey].toString());
        //var inicioSession = DateTime.parse(window.sessionStorage[_inicioSessionKey].toString());

        var d = expiresIn.difference(DateTime.now());
        sessionTimeOut =
            '${FrontUtils.addZero(d.inHours)}:${FrontUtils.addZero(d.inMinutes.remainder(60))}:${FrontUtils.addZero(d.inSeconds.remainder(60))}';

        document.querySelector('#authServiceSessionTimeOut')?.text =
            sessionTimeOut;
        var timeCount = d.inSeconds;
        //print('initPostAuth periodic ${timeCount}');

        if (timeCount <= 0) {
          timer.cancel();
          doLogout();
        }
      });
    }
  }

  Future<void> trocaSenha(
      String username, String senhaAtual, String novaSenha) async {
    final client = http.Client();
    final url = Uri.parse('${restConfig.backendUrl}/change/pass');
    final resp = await client.post(url,
        body: jsonEncode({
          'username': username,
          'senhaAtual': senhaAtual,
          'novaSenha': novaSenha,
        }),
        headers: restConfig.headers);

    if (resp.statusCode != 200) {
      throw Exception(RestError.fromJson(resp.bodyUtf8).exception);
    }
  }

  bool isPermitido(
      int? codAcao, int? codFuncionalidade, int? codModulo, int? codGestao) {
    return menus.where((m) {
      return m.codAcao == codAcao &&
          m.codFuncionalidade == codFuncionalidade &&
          m.codModulo == codModulo &&
          m.codGestao == codGestao;
    }).isNotEmpty;
  }

  /// verifica se o usuario tem permissão para acessar uma determinada pagina
  Future<bool> checkPermissao(int? codAcao, int? codFuncionalidade,
      int? codModulo, int? codGestao) async {
    var client = http.Client();
    var result = false;
    try {
      //print('checkPermissao isPermitido ${isPermitido(codAcao, codFuncionalidade, codModulo, codGestao)}');
      if (isPermitido(codAcao, codFuncionalidade, codModulo, codGestao)) {
        return true;
      }
      var cgmUserLogged = authPayload.numCgm;
      var url = Uri.parse(
          '${restConfig.backendUrl}/auth/check/permissao/$cgmUserLogged?a=$codAcao&f=$codFuncionalidade&m=$codModulo&g=$codGestao');
      var resp = await client.get(url, headers: restConfig.headers);
      //print('AuthService@checkPermissao ${resp.bodyUtf8}');
      if (resp.statusCode == 200) {
        result = true;
      } else {
        throw Exception('Não Permitido!');
      }
      return result;
    } catch (e, s) {
      print('AuthService@checkPermissao $e $s');
      return result;
    }
  }

  /// toda vez que o usuario da reloud na pagina faz uma nova checagem pra verificar se o usuario tem acesso
  /// ou seja verifica se esta logado
  Future<bool> checkToken() async {
    final client = http.Client();
    //print('checkToken');
    try {
      //loginStatus = LoginStatus.checking;
      
      final tokenData = window.sessionStorage[_accessTokenKey];
      if (tokenData == null || tokenData.isEmpty) {
        loginStatus = LoginStatus.notLogged;
        //onLogoutStreamController.add(loginStatus);
        return false;
      }
      menus = <MenuItem>[];
      final url = Uri.parse('${restConfig.backendUrl}/auth/check/token?t=${tokenData}');
      final resp = await client.get(url,
         // body: jsonEncode({'accessToken': tokenData}),
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
        throw SessionExpiredException();
      } else {
        throw Exception(resp.bodyUtf8);
      }
    } catch (e, s) {
      print('AuthService@checkToken $e $s');
      loginStatus = LoginStatus.notLogged;
      onLogoutStreamController.add(loginStatus);
      return false;
    }
  }

  //faz o login
  Future<bool> doLogin(LoginPayload loginPayload) async {
    var client = http.Client();
    var result = false;
    try {
      menus = <MenuItem>[];
      loginStatus = LoginStatus.checking;
      var url = Uri.parse('${restConfig.backendUrl}/auth/login');
      var response = await client.post(
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
      } else if (response.statusCode == 403) {
        var restEr = RestError.fromJson(response.bodyUtf8);
        throw Exception(restEr.exception);
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
