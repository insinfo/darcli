import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class Escolaridade implements SerializeBase {
  int id;
  String nome;
  Escolaridade({
    this.id = -1,
    required this.nome,
  });

  @override
  bool operator ==(o) => o is Escolaridade && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toMap() {
    return {
      'idescolaridade': id,
      'nome': nome,
    };
  }

  factory Escolaridade.fromMap(Map<String, dynamic> map) {
    return Escolaridade(
      id: map['idescolaridade']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
    );
  }
}
