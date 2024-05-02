import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class Pais implements SerializeBase {
  int id;
  String nome;
  Pais({
    this.id = -1,
    required this.nome,
  });

  @override
  bool operator ==(o) => o is Pais && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }

  factory Pais.fromMap(Map<String, dynamic> map) {
    return Pais(
      id: map['id']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
    );
  }
}
