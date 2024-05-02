import 'dart:convert';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:esic_core/esic_core.dart';

/// Adiciona funcionalidade a class ResponseContext
/// implementa o metodo responseJson e responseError que retorna JSON correto para o consumidor da API REST
extension ResponseContextExtensions on ResponseContext {
  ///  [value] - uma String JSON ou um Map<String,dynamic> para ser convertido em JSON utf-8
  /// e retornado para o frontend com status 200
  void responseJson(Object value, {int statusCode = 200}) {
    var v = value is String
        ? value
        : jsonEncode(value, toEncodable: CoreUtils.customJsonEncode);
    this.statusCode = statusCode;
    this.headers['Content-Type'] = 'application/json;charset=utf-8';
    this.write(v);
  }

  void responsePage(DataFrame dataPage, {int statusCode = 200}) {
    this.statusCode = statusCode;
    this.headers['Content-Type'] = 'application/json;charset=utf-8';
    this.headers['total-records'] = '${dataPage.totalRecords}';
    this.write(dataPage.toJson());
  }

  void responseHtml(String html, {int statusCode = 200}) {
    this.statusCode = statusCode;
    this.headers['Content-Type'] = 'text/html; charset=utf-8';
    this.write(html);
  }

  void responseErrorHtml(String erroMessage, {int statusCode = 400}) {
    var html = '''
<!DOCTYPE html>
<html>
<head>
  <title>E-SIC</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
 
  <link rel="icon" type="image/png" href="favicon.png"> 
</head>
<body style="background-color: #fff;align-items: center;font-size: 1.2rem;padding-top: 50px;">
 <p  style="text-align: center;"> 
  $erroMessage
 </p> 
</body>
</html>
''';
    this.statusCode = statusCode;
    this.headers['Content-Type'] = 'text/html; charset=utf-8';
    this.write(html);
  }

  /// metodo para retornar um JSON padrão quando houver erro
  ///   [message] - a mensagem do banco de dados
  ///   [exception] - o erro ocorrido
  ///   [stackTrace] - stacktrace do erro
  ///   [statusCode] - statusCode (O status, caso não seja passado, será assumido com o valor 400)
  ///
  /// Exemplo de uso: res.responseError(StatusMessage.LIST_ERROR_MESSAGE, exception:e, stackTrace:s, statusCode: 401);
  ///
  void responseError(String message,
      {dynamic exception, dynamic stackTrace, int statusCode = 400}) {
    var v = jsonEncode({
      'is_error': true,
      'status_code': statusCode,
      'message': message,
      'exception': exception?.toString(),
      'stackTrace': stackTrace?.toString()
    });
    this.statusCode = statusCode;
    this.headers['Content-Type'] = 'application/json;charset=utf-8';
    this.write(v);
  }
}
