import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class Municipio implements SerializeBase {
  int id;
  String nome;
  int estadoId;

  Municipio({
    this.id = -1,
    required this.nome,
    required this.estadoId,
  });

  @override
  bool operator ==(o) => o is Municipio && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'estado_id': estadoId,
    };
  }

  factory Municipio.fromMap(Map<String, dynamic> map) {
    return Municipio(
      id: map['id']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      estadoId: map['estado_id']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }
}
