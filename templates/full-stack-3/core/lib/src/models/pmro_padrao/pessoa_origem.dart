import 'package:sibem_core/core.dart';

class PessoaOrigem implements SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'pessoas_origens';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const ACAO_INSERIR = 'i';
  static const ACAO_UPDATE = 'u';
  static const ACAO_DELETE = 'r';

  int id; //! Obrigatorio
  int idPessoa; //! Obrigatorio
  DateTime dataAcao; //! Obrigatorio
  String sistemaOrigem; //! Obrigatorio
  String acao; //! Obrigatorio
  int? idPessoaResp;

  ///
  ///   'idPessoa': pessoa.id,
  ///   'dataAcao': DateTime.now(),
  ///   'sistemaOrigem': BANCO_EMPREGO,
  ///   'acao': 'i',
  ///   'idPessoaResp': idUsuarioLogado,
  ///
  PessoaOrigem({
    this.id = -1,
    required this.idPessoa,
    required this.dataAcao,
    required this.sistemaOrigem,
    required this.acao,
    this.idPessoaResp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idPessoa': idPessoa,
      'dataAcao': dataAcao.toIso8601String(),
      'sistemaOrigem': sistemaOrigem,
      'acao': acao,
      'idPessoaResp': idPessoaResp,
    };
  }

  factory PessoaOrigem.fromMap(Map<String, dynamic> map) {
    return PessoaOrigem(
      id: map['id'],
      idPessoa: map['idPessoa'] as int,
      dataAcao: map['dataAcao'] is String
          ? DateTime.parse(map['dataAcao'])
          : map['dataAcao'],
      sistemaOrigem: map['sistemaOrigem'] as String,
      acao: map['acao'] as String,
      idPessoaResp:
          map['idPessoaResp'] != null ? map['idPessoaResp'] as int : null,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()..remove('id');
  }

  @override
  String toString() {
    return 'PessoaOrigem(id: $id, idPessoa: $idPessoa, dataAcao: $dataAcao, sistemaOrigem: $sistemaOrigem, acao: $acao, idPessoaResp: $idPessoaResp)';
  }

  @override
  bool operator ==(covariant PessoaOrigem other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
