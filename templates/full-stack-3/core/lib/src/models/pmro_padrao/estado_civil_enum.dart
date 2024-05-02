enum EstadoCivil {
  solteiro,
  uniaoEstavel,
  casado,
  divorciado,
  viuvo,
  outros,
}

extension EstadoCivilExtension on EstadoCivil {
  /// Este metodo converte a enum em uma String para ser gravada no banco
  String get asString {
    switch (this) {
      case EstadoCivil.solteiro:
        return 'Solteiro';
      case EstadoCivil.uniaoEstavel:
        return 'Uniao Estável';
      case EstadoCivil.casado:
        return 'Casado';
      case EstadoCivil.divorciado:
        return 'Divorciado';
      case EstadoCivil.viuvo:
        return 'Viuvo';
      case EstadoCivil.outros:
        return 'Outros';
      default:
        throw Exception('EstadoCivil inválido');
    }
  }
}

EstadoCivil fromString(String tipo) {
  switch (tipo) {
    case 'Solteiro':
      return EstadoCivil.solteiro;
    case 'Uniao Estável':
      return EstadoCivil.uniaoEstavel;
    case 'Casado':
      return EstadoCivil.casado;
    case 'Divorciado':
      return EstadoCivil.divorciado;
    case 'Viuvo':
      return EstadoCivil.viuvo;
    case 'Outros':
      return EstadoCivil.outros;
    default:
      throw Exception('EstadoCivil inválido');
  }
}
