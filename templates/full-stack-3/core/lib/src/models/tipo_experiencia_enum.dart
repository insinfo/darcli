enum TipoExperiencia {
  informal,
  formal,
  mei,
}

final List<String> listaTipoExperiencia =
   TipoExperiencia.values.map((e) => e.asString).toList();

extension TipoExperienciaExtension on TipoExperiencia {
  String get asString {
    switch (this) {
      case TipoExperiencia.informal:
        return 'Informal';
      case TipoExperiencia.formal:
        return 'Formal';
      case TipoExperiencia.mei:
        return 'Mei';
      default:
        throw Exception('Tipo de experiência inválido');
    }
  }

  TipoExperiencia tipoVagaFromString(String tipo) {
    switch (tipo) {
      case 'Informal':
        return TipoExperiencia.informal;
      case 'Formal':
        return TipoExperiencia.formal;
      case 'Mei':
        return TipoExperiencia.mei;
      default:
        throw Exception('Tipo de experiência inválido');
    }
  }
}
