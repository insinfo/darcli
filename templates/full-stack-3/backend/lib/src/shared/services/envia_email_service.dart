import 'dart:typed_data';

import 'send_mail_gmail_api.dart';

///
///  Envia email

class EnviaEmailService {
  late SendMailGmailApi sendMailGmailApi;

  EnviaEmailService() {
    sendMailGmailApi = SendMailGmailApi();
  }

  List<String> toEmails = [];
  List<Attachment> attachments = [];

  String deEmail = 'email@gmail.com';
  String paraEmail = '';
  String assunto = 'app ::';
  String html = '';
  String? withBlindCopyTo;
  String? withCopyTo;

  void addDestinoEmail(String email) {
    toEmails.add(email);
  }

  Future<void> addAnexoStream(
      Stream<List<int>> _stream, String mimeType, String fileName) async {
    List<int> data = [];
    await for (var items in _stream) {
      data.addAll(items);
    }
    final bytes = Uint8List.fromList(data);
    final anexo =
        Attachment(bytes: bytes, mimeType: mimeType, fileName: fileName);
    attachments.add(anexo);
  }

  void addAnexo(Attachment anexo) {
    attachments.add(anexo);
  }

  Future<void> envia() async {
    if (paraEmail != '') {
      addDestinoEmail(paraEmail);
    }

    if (toEmails.isEmpty) {
      throw Exception('Não ha email destinatario definido!');
    }

    await sendMailGmailApi.sendWithAttachments(
        to: toEmails.length > 1 ? toEmails.join(', ') : toEmails.first,
        subject: assunto,
        message: html,
        withBlindCopyTo: withBlindCopyTo,
        withCopyTo: withCopyTo,
        from: deEmail,
        attachments: attachments);
  }
}
