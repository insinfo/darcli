import 'dart:convert';
import 'package:angel3_test/angel3_test.dart';
import 'package:angel3_validate/angel3_validate.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:new_sali_backend/src/shared/bootstrap.dart';
import 'package:test/test.dart';
import 'package:angel3_container/mirrors.dart';
import 'setup_integration.dart';

void main() {
  late Angel app;
  // late AngelHttp angelHttp;
  // late HttpServer server;
  late TestClient client;

  setUp(() async {
    // final logger = Logger.detached('sali')
    //   ..level = Level.ALL
    //   ..onRecord.listen(prettyLog);
    //logger: logger
    app = Angel(reflector: MirrorsReflector());
    //angelHttp = AngelHttp(app);
    await app.configure(configureServer);
    // server = await angelHttp.startServer('localhost', 3354);
    // print('sali server listening at ${angelHttp.uri}');

    client = await connectTo(app);
  });

  tearDown(() async {
    // await app.close();
    // await angelHttp.close();
    // await server.close(force: true);
    await client.close();
  });

  test('autenticar com sucesso', () async {
    final res = await client.post(Uri.parse('$baseUrl/auth/login'),
        body: jsonEncode({
          'username': 'isaque.santana',
          'password': 'Ins257257',
          'anoExercicio': DateTime.now().year.toString()
        }),
        headers: defaultHeaders);

    expect(
        res,
        allOf([
          // isJson({'foo': 'bar'}),
          hasStatus(200),
          //hasContentType(ContentType.json),
          hasContentType('application/json'),
          hasValidBody(Validator({
            'accessToken': isString,
            'numcgm': equals(140050),
            'nom_cgm': [isString, equals("Isaque Neves Sant'ana")],
            'username': equals('isaque.santana'),
            'ano_exercicio': DateTime.now().year.toString(),
            'nom_setor': isString,
            //'expiry': isA<DateTime>()
            'expiry': isString,
            'cpf': '13128250731',
            'ano_exercicio_setor': isString,
          })),
          // hasHeader('server'), // Assert header present
          // hasHeader('server', 'angel'), // Assert header present with value
          //  hasHeader('foo', ['bar', 'baz']), // ... Or multiple values
          //  hasBody(), // Assert non-empty body
          //  hasBody('{"foo":"bar"}') // Assert specific body
        ]));
  });

  test('autenticar com usuario não existente', () async {
    final res = await client.post(Uri.parse('$baseUrl/auth/login'),
        body: jsonEncode({
          'username': 'isaque.santana456',
          'password': 'teste',
          'anoExercicio': DateTime.now().year.toString()
        }),
        headers: defaultHeaders);

    expect(
        res,
        allOf([
          hasStatus(403),
          hasValidBody(Validator({
            'is_error': isBool,
            'exception': equals('UserNotFoundException'),
          })),
        ]));
  });

  test('autenticar com senha errada', () async {
    final res = await client.post(Uri.parse('$baseUrl/auth/login'),
        body: jsonEncode({
          'username': 'isaque.santana',
          'password': 'teste',
          'anoExercicio': DateTime.now().year.toString()
        }),
        headers: defaultHeaders);

    expect(
        res,
        allOf([
          hasStatus(401),
          hasValidBody(Validator({
            'is_error': isBool,
            'exception': equals('Senha incorreta! : 401'),
          })),
        ]));
  });

  test('verificar validade de token valido', () async {
    final token = await getTokenUser(client);

    final res =
        await client.get(Uri.parse('$baseUrl/auth/check/token?t=$token'));

    expect(
        res,
        allOf([
          hasStatus(200),
          hasValidBody(Validator({
            'expiry': isString,
            'login': equals(true),
          })),
        ]));
  });

  test('verificar permissão', () async {
    final session = await getSession(client);

    final res = await client.get(
        Uri.parse(
            '$baseUrl/auth/check/permissao/${session.numCgm}?a=67&f=19&m=5&g=1'),
        headers: defaultHeaders
          ..addAll({'Authorization': 'Bearer ${session.accessToken}'}));

    expect(
        res,
        allOf([
          hasStatus(200),
          hasValidBody(Validator({
            'expiry': isString,
            'login': equals(true),
          })),
        ]));
  });
}
