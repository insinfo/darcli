enum TipoPessoa {
  fisica,
  juridica,
  none,
}

final List<String> listaTipoPessoa =
    TipoPessoa.values.map((e) => e.asString).toList();

extension TipoPessoaExtension on TipoPessoa {
  /// Este metodo converte a enum em uma String para ser gravada no banco
  String get asString {
    switch (this) {
      case TipoPessoa.fisica:
        return 'fisica';
      case TipoPessoa.juridica:
        return 'juridica';
      default:
        throw Exception('Tipo de Pessoa inválido');
    }
  }
}

/// Este metodo converte uma String em uma enum do TipoPessoa
/// [tipo] este parametro recebe a String fisica | juridica
///
/// `Return` TipoPessoa
TipoPessoa tipoPessoaFromString(String tipo) {
  switch (tipo) {
    case 'fisica':
      return TipoPessoa.fisica;
    case 'Fisica':
      return TipoPessoa.fisica;
    case 'f':
      return TipoPessoa.fisica;
    case 'F':
      return TipoPessoa.fisica;
    case 'juridica':
      return TipoPessoa.juridica;
    case 'Juridica':
      return TipoPessoa.juridica;
    case 'j':
      return TipoPessoa.juridica;
    case 'J':
      return TipoPessoa.juridica;
    default:
      throw Exception('Tipo de Pessoa inválido - $tipo');
  }
}
