enum SexoBiologico {
  feminino,
  masculino,
}

extension SexoBiologicoExtension on SexoBiologico {
  String get asString {
    switch (this) {
      case SexoBiologico.feminino:
        return 'Feminino';
      case SexoBiologico.masculino:
        return 'Masculino';
      default:
        throw Exception('Sexo biológico inválido');
    }
  }
}

SexoBiologico sexoBiologicoFromString(String tipo) {
  switch (tipo) {
    case 'Feminino':
      return SexoBiologico.feminino;
    case 'Masculino':
      return SexoBiologico.masculino;
    default:
      throw Exception('Sexo biológico inválido');
  }
}
