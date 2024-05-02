import 'package:esic_core/esic_core.dart';

class Acao implements SerializeBase {
  int id;
  int idtela;
  String denominacao;
  String operacao;

  /// [A]tivo - [I]nativo
  String status;

  Acao({
    this.id = -1,
    required this.idtela,
    required this.denominacao,
    required this.operacao,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'idacao': id,
      'idtela': idtela,
      'denominacao': denominacao,
      'operacao': operacao,
      'status': status,
    };
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('idacao');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }

  factory Acao.fromMap(Map<String, dynamic> map) {
    return Acao(
      id: map['idacao']?.toInt() ?? 0,
      idtela: map['idtela']?.toInt() ?? 0,
      denominacao: map['denominacao'] ?? '',
      operacao: map['operacao'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
