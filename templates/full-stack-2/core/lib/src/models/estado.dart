import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class Estado implements SerializeBase {
  int id;
  String nome;
  String sigla;
  int? paisId;

  Estado({
    this.id = -1,
    required this.nome,
    required this.sigla,
    this.paisId,
  });

  @override
  bool operator ==(o) => o is Estado && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'sigla': sigla,
      'pais_id': paisId,
    };
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }

  factory Estado.fromMap(Map<String, dynamic> map) {
    return Estado(
      id: map['id']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      sigla: map['sigla'] ?? '',
      paisId: map['pais_id']?.toInt(),
    );
  }
}
