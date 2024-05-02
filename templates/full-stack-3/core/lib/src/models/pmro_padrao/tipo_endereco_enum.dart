enum TipoEndereco {
  residencial,
  comercial,
}

final List<String> listaTipoEnderecoPmro =
    TipoEndereco.values.map((e) => e.asString).toList();

extension TipoEnderecoExtension on TipoEndereco {
  String get asString {
    switch (this) {
      case TipoEndereco.comercial:
        return 'Comercial';
      case TipoEndereco.residencial:
        return 'Residencial';
      default:
        throw Exception('Tipo de Endereço inválido');
    }
  }
}

TipoEndereco tipoEnderecoFromString(String tipo) {
  switch (tipo) {
    case 'Comercial':
      return TipoEndereco.comercial;
    case 'Reidencial':
      return TipoEndereco.residencial;
    default:
      throw Exception('Tipo de Endereço inválido');
  }
}
