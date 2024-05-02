import 'dart:convert';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_test/angel3_test.dart';
import 'package:http/http.dart';
import 'package:angel3_container/mirrors.dart';
import 'package:new_sali_backend/src/shared/bootstrap.dart';
import 'package:new_sali_core/new_sali_core.dart';

import 'helpers.dart';

Map<String, String> defaultHeaders = {
  "content-type": 'application/json; charset=utf-8',
  "accept": 'application/json; charset=utf-8',
};

String baseUrl = 'http://localhost:3354/api/v1';

/// inicializa o angel
Future<TestClient> setupAngel() async {
  // final logger = Logger.detached('sali')
  //   ..level = Level.ALL
  //   ..onRecord.listen(prettyLog);
  //logger: logger
  final app = Angel(reflector: MirrorsReflector());
  //angelHttp = AngelHttp(app);
  await app.configure(configureServer);
  // server = await angelHttp.startServer('localhost', 3354);
  // print('sali server listening at ${angelHttp.uri}');

  final client = await connectTo(app);
  return client;
}

/// função utilitaria para ajudar nos testes
/// faz a autenticação no backend
Future<Response> authenticate(TestClient client,
    {username = 'isaque.santana', password = 'Ins257257'}) async {
  final respLogin = await client.post(Uri.parse('$baseUrl/auth/login'),
      body: jsonEncode({
        'username': username,
        'password': password,
        'anoExercicio': DateTime.now().year.toString()
      }),
      headers: defaultHeaders);
  return respLogin;
}

/// função utilitaria para ajudar nos testes
/// cadastra um processo e retorna o codigo/ano
Future<String> incluirProcesso(TestClient client, {int codSituacao = 2}) async {
  final res = await client.post(Uri.parse('$baseUrl/protocolo/processos'),
      body: jsonEncode({
        'cod_processo': -1,
        'ano_exercicio': '2023',
        'cod_classificacao': 169,
        'cod_assunto': 1,
        'numcgm': 140050,
        'cod_usuario': 140050,
        'cod_situacao': codSituacao,
        'timestamp': '2023-10-09T11:09:01.955',
        'observacoes': 'Objeto teste',
        'confidencial': false,
        'resumo_assunto': '',
        'id_setor': 524,
        'andamentos': [
          {
            'cod_andamento': 1,
            'cod_processo': -1,
            'ano_exercicio': '2023',
            'cod_orgao': 2,
            'cod_unidade': 89,
            'cod_departamento': 2,
            'cod_setor': 1,
            'ano_exercicio_setor': '2003',
            // 140050 isaque.santana
            'cod_usuario': 140050,
            'timestamp': '2023-10-09T11:09:01.955',
            'nome_setor_destino': 'TI - Tecnologia da Informação'
          }
        ],
      }),
      headers: defaultHeaders..addAll(await getAuthorizationHeader(client)));
  final result = res.bodyAsMap();
  final cod = result['cod_processo'].toString() +
      '/' +
      result['ano_exercicio'].toString();
  print('setup.dart incluirProcesso: ${cod}');
  return cod;
}

Future<void> receberProcesso(TestClient client,
    {required int codUltimoAndamento,
    required int codProcesso,
    required String anoExercicio}) async {
  final res2 = await client.post(
      Uri.parse('$baseUrl/protocolo/processos/receber/lote'),
      body: jsonEncode([
        {
          "codUltimoAndamento": codUltimoAndamento,
          "codProcesso": codProcesso,
          "anoExercicio": anoExercicio,
        }
      ]),
      headers: defaultHeaders..addAll(await getAuthorizationHeader(client)));

  print('setup.dart receberProcesso: ${res2.bodyAsMap()}');

  if (res2.statusCode != 200) {
    throw Exception('Não foi possivel receber este processo');
  }
}

Future<AuthPayload> getSession(TestClient client) async {
  final respLogin = await authenticate(client);
  final map = jsonDecode(respLogin.body);
  return AuthPayload.fromMap(map);
}

Future<String> getTokenUser(TestClient client) async {
  final respLogin = await authenticate(client);
  final map = jsonDecode(respLogin.body);
  return map['accessToken'];
}

Future<Map<String, String>> getAuthorizationHeader(TestClient client) async {
  final respLogin = await authenticate(client);
  final map = jsonDecode(respLogin.body);
  return {'Authorization': 'Bearer ' + map['accessToken']};
}

Future<int> getCgmUser(TestClient client) async {
  final respLogin = await authenticate(client);
  final map = jsonDecode(respLogin.body);
  return map['numcgm'];
}
