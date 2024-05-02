enum IdentidadeGenero {
  heteroafetivo,
  homoafetivo,
  bissexual,
  transgenero,
  travesti,
  outros,
}

final List<String> listaIdentidadeGenero =
    IdentidadeGenero.values.map((e) => e.asString).toList();

extension IdentidadeGeneroExtension on IdentidadeGenero {
  String get asString {
    switch (this) {
      case IdentidadeGenero.heteroafetivo:
        return 'Heteroafetivo';
      case IdentidadeGenero.homoafetivo:
        return 'Homoafetivo';
      case IdentidadeGenero.bissexual:
        return 'Bissexual';
      case IdentidadeGenero.transgenero:
        return 'Transgenero';
      case IdentidadeGenero.travesti:
        return 'Travesti';
      case IdentidadeGenero.outros:
        return 'Outros';
      default:
        throw Exception('Identidade de genero inválido');
    }
  }
}

IdentidadeGenero indentidadeGeneroFromString(String tipo) {
  switch (tipo) {
    case 'Heteroafetivo':
      return IdentidadeGenero.heteroafetivo;
    case 'Homoafetivo':
      return IdentidadeGenero.homoafetivo;
    case 'Bissexual':
      return IdentidadeGenero.bissexual;
    case 'Transgenero':
      return IdentidadeGenero.transgenero;
    case 'Travesti':
      return IdentidadeGenero.travesti;
    case 'Outros':
      return IdentidadeGenero.outros;
    default:
      throw Exception('Identidade de genero inválido');
  }
}
