import 'package:sibem_core/core.dart';

class Bairro implements SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'bairros';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  int idMunicipio;
  String nome;

  String? ibge;
  bool? validacaoCorreio;
  bool? oficial;

  Bairro({
    this.id = -1,
    required this.idMunicipio,
    required this.nome,
    this.ibge,
    this.validacaoCorreio,
    this.oficial,
  });

  factory Bairro.fromMap(Map<String, dynamic> map) {
    return Bairro(
        id: map['id'],
        idMunicipio: map['idMunicipio'],
        nome: map['nome'],
        ibge: map['ibge'],
        validacaoCorreio: map['validacaoCorreio'],
        oficial: map['oficial']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idMunicipio': idMunicipio,
      'nome': nome,
      'ibge': ibge,
      'validacaoCorreio': validacaoCorreio,
      'oficial': oficial
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }

  @override
  bool operator ==(covariant Bairro other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
