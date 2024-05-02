import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class TipoTelefone implements SerializeBase {
  int id;
  String nome;
  TipoTelefone({
    this.id = -1,
    required this.nome,
  });

  @override
  bool operator ==(o) => o is TipoTelefone && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toMap() {
    return {
      'idipotelefone': id,
      'nome': nome,
    };
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('idipotelefone');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }

  factory TipoTelefone.fromMap(Map<String, dynamic> map) {
    return TipoTelefone(
      id: map['idtipotelefone']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
    );
  }
}
