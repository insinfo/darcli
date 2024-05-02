enum PessoaTipo { fisica, juridica }

extension PessoaTipoExtension on PessoaTipo {
  /// Este metodo converte a enum em uma String para ser gravada no banco
  String get asString {
    switch (this) {
      case PessoaTipo.fisica:
        return 'fisica';
      case PessoaTipo.juridica:
        return 'juridica';
      default:
        throw Exception('PessoaTipo inválido');
    }
  }
}

PessoaTipo pessoaTipoFromString(String tipo) {
  switch (tipo) {
    case 'fisica':
      return PessoaTipo.fisica;
    case 'juridica':
      return PessoaTipo.juridica;
    default:
      throw Exception('EstadoCivil inválido');
  }
}
