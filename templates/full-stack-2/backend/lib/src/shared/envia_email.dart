import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

///
///  Envia email
class EnviaEmail {
  //Sua senha de aplicativo
  //yahoo Sua senha de aplicativo única para city é:
  //rrskbxbpthglcuhp
  EnviaEmail() {
    smtpServer = SmtpServer(     
      'smtp.gmail.com',     
      username: 'username',
      password: 'pass', 
      port: 587,
    );
    message = Message();
  }
  late SmtpServer smtpServer;
  late Message message;

  void addFileData(Stream<List<int>> _stream, String contentType,
      {String? fileName}) {
    final attachment =
        StreamAttachment(_stream, contentType, fileName: fileName);
    message.attachments.add(attachment);
  }

  String deEmail = 'email@outlook.com';
  String deNome = 'ESIC';
  String paraEmail = '';
  String assunto = 'ESIC ::';
  String html = '';

  void addDestinoEmail(String email) {
    message.recipients.add(email);
  }

  Future<SendReport> envia() async {
    message.from = Address(deEmail, deNome);
    message.recipients.add(paraEmail);
    message.subject =
        assunto; //'PORTAL TURISMO :: FORMULÁRIO PARA ENTRADA DE EXCURSÃO';
    message.html = html;
    return await send(message, smtpServer);
  }
}
