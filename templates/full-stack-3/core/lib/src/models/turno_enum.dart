enum Turno {
  Integral,
  Matutino,
  Noturno,
  Vespertino,
}

final List<String> listaTurnoSibem = Turno.values.map((e) => e.asString).toList();

extension TurnoExtension on Turno {
  String get asString {
    switch (this) {
      case Turno.Integral:
        return 'integral';
      case Turno.Matutino:
        return 'matutino';
      case Turno.Noturno:
        return 'noturno';
      case Turno.Vespertino:
        return 'vespertino';
      default:
        throw Exception('Turno inválido');
    }
  }
}

Turno turnoFromString(String tipo) {
  switch (tipo) {
    case 'Integral':
      return Turno.Integral;
    case 'Matutino':
      return Turno.Matutino;
    case 'Noturno':
      return Turno.Noturno;
    case 'Vespertino':
      return Turno.Vespertino;
    default:
      throw Exception('Turno inválido');
  }
}
