enum TipoCurso {
  tecnico,
  superior,
  extensao,
  posGraduacao,
  mestrado,
  doutorado,
  offshore,
  extras,
}

extension TipoCursoExtension on TipoCurso {
  List<String> get listaTipoCurso =>
      TipoCurso.values.map((e) => e.asString).toList();

  String get asString {
    switch (this) {
      case TipoCurso.tecnico:
        return 'Técnico';
      case TipoCurso.superior:
        return 'Superior';
      case TipoCurso.extensao:
        return 'Extensão';
      case TipoCurso.posGraduacao:
        return 'Pos-graduação';
      case TipoCurso.mestrado:
        return 'Mestrado';
      case TipoCurso.doutorado:
        return 'Doutorado';
      case TipoCurso.offshore:
        return 'Offshore';
      case TipoCurso.extras:
        return 'Extras';
      default:
        throw Exception('Tipo de curso inválido');
    }
  }
}

TipoCurso tipoCursoFromString(String tipo) {
  switch (tipo) {
    case 'Técnico':
      return TipoCurso.tecnico;
    case 'Superior':
      return TipoCurso.superior;
    case 'Extensão':
      return TipoCurso.extensao;
    case 'graduação':
      return TipoCurso.posGraduacao;
    case 'Mestrado':
      return TipoCurso.mestrado;
    case 'Doutorado':
      return TipoCurso.doutorado;
    case 'Offshore':
      return TipoCurso.offshore;
    case 'Extras':
      return TipoCurso.extras;
    default:
      throw Exception('Tipo de curso inválido');
  }
}
