import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class Bairro implements SerializeBase {
  static String TableName = 'gen_bairros';
  int id;
  int municipio_id;
  String nome;

  Bairro({
    this.id = -1,
    required this.municipio_id,
    required this.nome,
  });

  @override
  bool operator ==(o) => o is Bairro && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'municipio_id': municipio_id,
      'nome': nome,
    };
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }

  factory Bairro.fromMap(Map<String, dynamic> map) {
    return Bairro(
      id: map['id']?.toInt() ?? 0,
      municipio_id: map['municipio_id']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
    );
  }
}
