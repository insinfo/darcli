import 'package:esic_core/esic_core.dart';
import 'package:esic_core/src/utils/hash.dart';

class FaixaEtaria implements SerializeBase {
  int id;
  String nome;
  FaixaEtaria({
    this.id = -1,
    required this.nome,
  });

  @override
  bool operator ==(o) => o is FaixaEtaria && nome == o.nome && id == o.id;

  @override
  int get hashCode => hash2(nome.hashCode, id.hashCode);

  Map<String, dynamic> toMap() {
    return {
      'idfaixaetaria': id,
      'nome': nome,
    };
  }

  factory FaixaEtaria.fromMap(Map<String, dynamic> map) {
    return FaixaEtaria(
      id: map['idfaixaetaria']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
    );
  }
}
