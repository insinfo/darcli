import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class Cargo implements SerializeBase {
  int id;
  String nome;

  Cargo({
    this.id = -1,
    required this.nome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  @override
  bool operator ==(o) => o is Cargo && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }

  factory Cargo.fromMap(Map<String, dynamic> map) {
    return Cargo(
      id: map['id']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
    );
  }
}
