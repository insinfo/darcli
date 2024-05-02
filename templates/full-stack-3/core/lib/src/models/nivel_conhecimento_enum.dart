enum NivelConhecimento {
  basico,
  intermediario,
  avancado,
}

final List<String> listaNivelConhecimento =
    NivelConhecimento.values.map((e) => e.asString).toList();

extension NivelConhecimentoExtension on NivelConhecimento {
  String get asString {
    switch (this) {
      case NivelConhecimento.basico:
        return 'Básico';
      case NivelConhecimento.intermediario:
        return 'Intermediário';
      case NivelConhecimento.avancado:
        return 'Avançado';
      default:
        throw Exception('Nivel de conhecimento inválido');
    }
  }
}

NivelConhecimento nivelConhecimentoFromString(String tipo) {
  switch (tipo) {
    case 'Básico':
      return NivelConhecimento.basico;
    case 'Intermediário':
      return NivelConhecimento.intermediario;
    case 'Avançado':
      return NivelConhecimento.avancado;
    default:
      throw Exception('Nivel de conhecimento inválido');
  }
}
