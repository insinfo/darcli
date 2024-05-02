enum TipoTelefone {
  comercial,
  movel,
  residencial,
  whatsapp,
}

final List<String> listaTipoTelefone =
    TipoTelefone.values.map((e) => e.asString).toList();

extension TipoTelefoneExtension on TipoTelefone {
  String get asString {
    switch (this) {
      case TipoTelefone.comercial:
        return 'Comercial';
      case TipoTelefone.movel:
        return 'Móvel';
      case TipoTelefone.residencial:
        return 'Residencial';
      case TipoTelefone.whatsapp:
        return 'WhatsApp';
      default:
        throw Exception('Tipo de telefone inválido');
    }
  }
}

TipoTelefone tipoTelefoneFromString(String tipo) {
  switch (tipo) {
    case 'Comercial':
      return TipoTelefone.comercial;
    case 'Móvel':
      return TipoTelefone.movel;
    case 'Residencial':
      return TipoTelefone.residencial;
    case 'WhatsApp':
      return TipoTelefone.whatsapp;
    default:
      throw Exception('Tipo de telefone inválido');
  }
}
