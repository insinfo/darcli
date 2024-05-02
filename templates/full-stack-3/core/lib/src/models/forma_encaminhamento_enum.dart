enum FormaEncaminhamento {
  email,
  whatsapp,
  presencial,
}

final List<String> listaFormaEncaminhamentoSibem =
    FormaEncaminhamento.values.map((e) => e.asString).toList();

extension FormaEncaminhamentoExtension on FormaEncaminhamento {
  String get asString {
    switch (this) {
      case FormaEncaminhamento.email:
        return 'Email';
      case FormaEncaminhamento.whatsapp:
        return 'WhatsApp';
      case FormaEncaminhamento.presencial:
        return 'Presencial';
      default:
        throw Exception('Forma de encaminhamento inválido');
    }
  }
}

FormaEncaminhamento formaEncaminhamentoFromString(String tipo) {
  switch (tipo) {
    case 'Email':
      return FormaEncaminhamento.email;
    case 'WhatsApp':
      return FormaEncaminhamento.whatsapp;
    case 'Presencial':
      return FormaEncaminhamento.presencial;
    default:
      throw Exception('Forma de encaminhamento inválido');
  }
}
