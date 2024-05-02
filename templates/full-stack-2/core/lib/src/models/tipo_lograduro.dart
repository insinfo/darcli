import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class TipoLograduro implements SerializeBase {
  int id;
  String nome;
  bool ativo;

  TipoLograduro({
    required this.id,
    required this.nome,
    required this.ativo,
  });

  @override
  bool operator ==(o) => o is TipoLograduro && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ativo': ativo,
    };
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('id');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }

  factory TipoLograduro.fromMap(Map<String, dynamic> map) {
    return TipoLograduro(
      id: map['id']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      ativo: map['ativo'] ?? false,
    );
  }
}
