import 'package:sibem_core/core.dart';

class Telefone extends SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'telefones';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idPessoaFqCol = '$tableName.$idPessoaCol';
  static const String idPessoaCol = 'idPessoa';

  /// Obrigatorio
  int id;

  /// Obrigatorio
  int idPessoa;

  /// Obrigatorio
  String tipo;

  /// Obrigatorio
  String numero;

  Telefone({
    required this.id,
    required this.idPessoa,
    required this.tipo,
    required this.numero,
  });

  factory Telefone.invalid() {
    return Telefone(
      id: -1,
      idPessoa: -1,
      tipo: 'Comercial',
      numero: '',
    );
  }

  factory Telefone.fromMap(Map<String, dynamic> map) {
    return Telefone(
      id: map['id'],
      idPessoa: map['idPessoa'],
      tipo: map['tipo'],
      numero: map['numero'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idPessoa': idPessoa,
      'tipo': tipo,
      'numero': numero,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }

  @override
  String toString() {
    return 'Telefone(id:$id, idPessoa: $idPessoa, tipo: $tipo, numero: $numero)';
  }
}
