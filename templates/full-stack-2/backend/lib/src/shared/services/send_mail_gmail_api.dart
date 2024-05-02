import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import "package:path/path.dart";
import 'package:mime/mime.dart';

class Attachment {
  final Uint8List bytes;
  final String mimeType;
  final String fileName;
  Attachment({
    required this.bytes,
    required this.mimeType,
    required this.fileName,
  });
}

final __DIR__ = Directory.current.path; 


class SendMailGmailApi {
  String apiKey = 'key';
  String accessToken =
      "token";
  String tokenPath = __DIR__ + "/.accessToken.conf";
  String clientId =
      'clientId'; //aplication desktop
  String clientSecret =
      'clientSecret'; //aplication desktop
  String redirectUri =
      'urn:ietf:wg:oauth:2.0:oob'; 
  String scope = 'https://mail.google.com';
  String userAgent = 'ESIC';
  String projectId = "projectId";
  String authUri = "https://accounts.google.com/o/oauth2/auth";
  String tokenUri = "https://oauth2.googleapis.com/token";
  String authProviderX509CertUrl = 'https://www.googleapis.com/oauth2/v1/certs';
  //obtem o codigo_autorizacao com a URL abaixo
  //https://accounts.google.com/o/oauth2/v2/auth?client_id=406592931315-js80v3881f2v56c11v7kr1j0jj1nuf11.apps.googleusercontent.com&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=https://mail.google.com&response_type=code
  //e depois com a função getRefreshToken pega refresh_token
  String refreshToken =
      "123";
  //inicializa a class com as configurações de conta 
  String clientSecretFile = __DIR__ + "/client_secret_desktop_desenv.json";
  String origin = 'https://app.site.com';

  SendMailGmailApi(
      {String pClientSecretFile = 'null',
      String pRefreshToken = 'null',
      String pApiKey = 'null'}) {
    if (pClientSecretFile != 'null') {
      this.clientSecretFile = pClientSecretFile;
    }
    if (pRefreshToken != 'null') {
      this.refreshToken = pRefreshToken;
    }
    if (pApiKey != 'null') {
      this.apiKey = pApiKey;
    }
    _init();
    //load the last session token
    if (File(tokenPath).existsSync()) {
      accessToken = File(tokenPath).readAsStringSync();
    }
  }

  ///  inicializa a class com as configurações do arquivo client_secret.json
  void _init() {
   

    if (clientSecretFile != 'null' && File(clientSecretFile).existsSync()) {
      Map confs = jsonDecode(File(clientSecretFile).readAsStringSync());
      if (confs.containsKey('installed')) {
        confs = confs['installed'];
      } else if (confs.containsKey('web')) {
        confs = confs['web'];
      }
      clientId = confs['client_id'];
      projectId = confs['project_id'];
      authUri = confs['auth_uri'];
      tokenUri = confs['token_uri'];
      authProviderX509CertUrl = confs['auth_provider_x509_cert_url'];
      clientSecret = confs['client_secret'];
      redirectUri = confs['redirect_uris'][0];
    }
  }

  Future<dynamic> send({
    String to = 'desenv.pmro@gmail.com',
    String subject = 'subject',
    String message = "message",
    String? withBlindCopyTo,
    String? withCopyTo,
    String from = 'desenv.pmro@gmail.com',
  }) async {
    await refreshOAuthToken();
   
    final blindCarbonCopy =
        withBlindCopyTo == null ? '' : 'bcc: $withBlindCopyTo\r\n';
    final carbonCopy = withCopyTo == null ? '' : 'cc: $withCopyTo\r\n';
    
    var email = [
      'From: $from\r\n',
      'To: $to\r\n',
      carbonCopy,
      blindCarbonCopy,
      'Subject: ${_encode(subject)}\r\n',
      "Content-Type: text/html; charset=UTF-8\r\n",
      'Content-Transfer-Encoding: base64\r\n\r\n',
      base64Encode(utf8.encode('<html><body>$message</body></html>')),
    ];

    var msgBase64 = base64Encode(utf8.encode(email.join('')));
    msgBase64 = msgBase64.replaceAll('+', '-');
    msgBase64 = msgBase64.replaceAll('/', '_');
    //msgBase64 = msgBase64.replaceAll( '=', '*');
    var userId = "me"; //==$from
    final resp = await http.post(
        Uri.parse(
            "https://gmail.googleapis.com/gmail/v1/users/$userId/messages/send?key=$apiKey"),
        headers: {
          'user-agent': userAgent,
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'raw': msgBase64}));
    if (resp.statusCode == 200) {
      // echo 'email send success';
      return true;
    } else {
      throw Exception("to Exception: ${resp.body}");
    }
  }

  Future<dynamic> sendWithFiles({
    String to = 'email@gmail.com',
    String subject = 'subject',
    String message = 'message',
    String? withBlindCopyTo,
    String? withCopyTo,
    String from = 'email@gmail.com',
    required List<File> files,
  }) async {
    await refreshOAuthToken();

   
    final blindCarbonCopy =
        withBlindCopyTo == null ? '' : 'bcc: $withBlindCopyTo\r\n';
    final carbonCopy = withCopyTo == null ? '' : 'cc: $withCopyTo\r\n';
    var boundary = 'foo_bar_baz';
    var mail = [
      'Content-Type: multipart/mixed; boundary="$boundary"\r\n',
      'MIME-Version: 1.0\r\n',
      "From: $from\r\n",
      "To: $to\r\n",
      carbonCopy,
      blindCarbonCopy,
      'Subject: ${_encode(subject)}\r\n\r\n',
      '--$boundary\r\n',
      "Content-Type: text/html; charset=UTF-8\r\n",
      'MIME-Version: 1.0\r\n',
      "Content-Transfer-Encoding: base64\r\n\r\n",
      base64Encode(utf8.encode('<html><body>$message</body></html>')),
      '\r\n\r\n',
    ];

    for (var file in files) {
      mail.add('--foo_bar_baz\r\n');
      final mimeType = lookupMimeType(file.path);
      mail.add('Content-Type: $mimeType\r\n');
      mail.add('MIME-Version: 1.0\r\n');
      mail.add('Content-Transfer-Encoding: base64\r\n');
      final filename = basename(file.path);
      mail.add('Content-Disposition: attachment; filename="$filename"\r\n\r\n');
      final msgBase64 = base64Encode(await file.readAsBytes());
      mail.add(msgBase64);
      mail.add('\r\n\r\n');
    }

    mail.add('--foo_bar_baz--');
    final body = mail.join('');
    var userId = "me"; //==$from
    final resp = await http.post(
        Uri.parse(
            "https://www.googleapis.com/upload/gmail/v1/users/$userId/messages/send?uploadType=multipart&key=$apiKey"),
        headers: {
          'user-agent': userAgent,
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'message/rfc822'
        },
        body: body);

    if (resp.statusCode == 200) {
      // echo 'email send success';

      return true;
    } else {
      throw Exception("to Exception: ${resp.body}");
    }
  }

  //

  Future<dynamic> sendWithAttachments({
    String to = 'email@gmail.com',
    String subject = 'subject',
    String message = 'message',
    String? withBlindCopyTo,
    String? withCopyTo,
    String from = 'email@gmail.com',
    List<Attachment>? attachments,
  }) async {
    await refreshOAuthToken();
    
    final blindCarbonCopy =
        withBlindCopyTo == null ? '' : 'bcc: $withBlindCopyTo\r\n';
    final carbonCopy = withCopyTo == null ? '' : 'cc: $withCopyTo\r\n';
    var boundary = 'foo_bar_baz';
    var mail = [
      'Content-Type: multipart/mixed; boundary="$boundary"\r\n',
      'MIME-Version: 1.0\r\n',
      "From: $from\r\n",
      "To: $to\r\n",
      carbonCopy,
      blindCarbonCopy,
      'Subject: ${_encode(subject)}\r\n\r\n',
      '--$boundary\r\n',
      "Content-Type: text/html; charset=UTF-8\r\n",
      'MIME-Version: 1.0\r\n',
      "Content-Transfer-Encoding: base64\r\n\r\n",
      base64Encode(utf8.encode('<html><body>$message</body></html>')),
      '\r\n\r\n',
    ];

    if (attachments != null) {
      for (var attachment in attachments) {
        mail.add('--foo_bar_baz\r\n');
        mail.add('Content-Type: ${attachment.mimeType}\r\n');
        mail.add('MIME-Version: 1.0\r\n');
        mail.add('Content-Transfer-Encoding: base64\r\n');
        mail.add(
            'Content-Disposition: attachment; filename="${attachment.fileName}"\r\n\r\n');
        final msgBase64 = base64Encode(await attachment.bytes);
        mail.add(msgBase64);
        mail.add('\r\n\r\n');
      }
    }
    mail.add('--foo_bar_baz--');
    final body = mail.join('');
    var userId = "me"; //==$from
    final resp = await http.post(
        Uri.parse(
            "https://www.googleapis.com/upload/gmail/v1/users/$userId/messages/send?uploadType=multipart&key=$apiKey"),
        headers: {
          'user-agent': userAgent,
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'message/rfc822'
        },
        body: body);
    if (resp.statusCode == 200) {
      // echo 'email send success';
      return true;
    } else {
      throw Exception("sendWithAttachments Exception: ${resp.body}");
    }
  }

// UTF-8 characters in names and subject
  String _encode(String subject) {
    var enc_subject = base64Encode(utf8.encode(subject));
    return '=?utf-8?B?' + enc_subject + '?=';
  }

  Future<void> refreshOAuthToken() async {
   
    final isTokenExpired = await isAccessTokenExpired();
    if (isTokenExpired == false) {
      return;
    }

  
    final resp = await http.post(
        Uri.parse('https://accounts.google.com/o/oauth2/token'),
        headers: {
          'user-agent': userAgent,       
          'accept': '*/*'
        },
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token'
        });

    if (resp.statusCode == 200) {
      accessToken = jsonDecode(resp.body)['access_token'];

      File(tokenPath).writeAsStringSync(accessToken);
    } else {
      throw Exception("refreshToken:\r\n${resp.body}");
    }
  }

  Future<bool> isAccessTokenExpired() async {
    final resp = await http.get(
        Uri.parse(
            'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$accessToken'),
        headers: {
          'user-agent': userAgent,
          'Accept': 'Accept: */*',
        });

    if (resp.statusCode == 200) {
      //echo "isAccessTokenExpired false\r\n";
      return false;
    } else {
      //throw new Exception($data);
      return true;
    }
  }

  /// URL para Solicitar consentimento do usuário
  /// Abra esta url no navegador
  String getRequestUserConsentUrl() {
    return "https://accounts.google.com/o/oauth2/v2/auth?client_id=$clientId" +
        "&redirect_uri=$redirectUri" +
        "&scope=$scope" +
        "&response_type=code";
  }

  /// pega um refresh_token e access_token
  Future<String> getRefreshToken(String codigoAutorizacao) async {
    final resp = await http.post(
        Uri.parse("https://accounts.google.com/o/oauth2/token"),
        headers: {
          'user-agent': userAgent,
          'Origin': 'https://app.site.com'
        },
        body: {
          'code': codigoAutorizacao,
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code'
        });

  
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)['refresh_token'];
    } else {
      throw Exception('getRefreshToken:\r\n${resp.body}');
    }
  }
}
