import 'package:sibem_core/core.dart';

class PessoaEndereco extends SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'pessoas_enderecos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  int idPessoa;
  int idEndereco;
  TipoEndereco tipo;
  String? numero;
  String? complemento;

  PessoaEndereco({
    required this.id,
    required this.idPessoa,
    required this.idEndereco,
    required this.tipo,
    this.numero,
    this.complemento,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idPessoa': idPessoa,
      'idEndereco': idEndereco,
      'tipo': tipo.asString,
      'numero': numero,
      'complemento': complemento,
    };
  }

  factory PessoaEndereco.fromMap(Map<String, dynamic> map) {
    return PessoaEndereco(
      id: map['id'] as int,
      idPessoa: map['idPessoa'] as int,
      idEndereco: map['idEndereco'] as int,
      tipo: tipoEnderecoFromString(map['tipo']),
      numero: map['numero'] != null ? map['numero'] as String : null,
      complemento:
          map['complemento'] != null ? map['complemento'] as String : null,
    );
  }

  @override
  String toString() {
    return 'PessoaEndereco(id: $id, idPessoa: $idPessoa, idEndereco: $idEndereco, tipo: $tipo, numero: $numero, complemento: $complemento)';
  }

  @override
  bool operator ==(covariant PessoaEndereco other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
