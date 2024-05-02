enum TipoVaga {
  estagio,
  jovemAprendiz,
  normal,
  primeiroEmprego,
  trainee,
  junior,
  pleno,
  senior,
  temporaria,
  outros,
}

final List<String> listaTipoVagaSibem =
   TipoVaga.values.map((e) => e.asString).toList();

extension TipoVagaExtension on TipoVaga {
  String get asString {
    switch (this) {
      case TipoVaga.estagio:
        return 'Estágio';
      case TipoVaga.jovemAprendiz:
        return 'Jovem Aprendiz';
      case TipoVaga.normal:
        return 'Normal';
      case TipoVaga.primeiroEmprego:
        return 'Primeiro Emprego';
      case TipoVaga.trainee:
        return 'Trainee';
      case TipoVaga.junior:
        return 'Junior';
      case TipoVaga.pleno:
        return 'Pleno';
      case TipoVaga.senior:
        return 'Senior';
      case TipoVaga.temporaria:
        return 'Temporária';
      case TipoVaga.outros:
        return 'Outros';
      default:
        throw Exception('Tipo de vaga inválido');
    }
  }
}

TipoVaga tipoVagaFromString(String tipo) {
  switch (tipo) {
    case 'Estágio':
      return TipoVaga.estagio;
    case 'Aprendiz':
      return TipoVaga.jovemAprendiz;
    case 'Normal':
      return TipoVaga.normal;
    case 'Emprego':
      return TipoVaga.primeiroEmprego;
    case 'Trainee':
      return TipoVaga.trainee;
    case 'Junior':
      return TipoVaga.junior;
    case 'Pleno':
      return TipoVaga.pleno;
    case 'Senior':
      return TipoVaga.senior;
    case 'Temporária':
      return TipoVaga.temporaria;
    case 'Outros':
      return TipoVaga.outros;
    default:
      throw Exception('Tipo de vaga inválido');
  }
}
