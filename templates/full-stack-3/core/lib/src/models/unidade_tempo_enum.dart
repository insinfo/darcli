enum UnidadeTempo {
  meses,
  anos,
}

final List<String> listaUnidadeTempo = UnidadeTempo.values.map((e) => e.asString).toList();

extension UnidadeTempoExtension on UnidadeTempo {
  String get asString {
    switch (this) {
      case UnidadeTempo.anos:
        return 'anos';
      case UnidadeTempo.meses:
        return 'meses';
      default:
        throw Exception('Unidade de tempo inválida');
    }
  }
}

UnidadeTempo unidadeTempoFromString(String tipo) {
  switch (tipo) {
    case 'meses':
      return UnidadeTempo.meses;
    case 'anos':
      return UnidadeTempo.anos;
    default:
      throw Exception('Unidade de tempo inválida');
  }
}
