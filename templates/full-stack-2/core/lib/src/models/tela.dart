import 'package:esic_core/esic_core.dart';

class Tela implements SerializeBase {
  int id;
  int idmenu;
  String pasta;
  String nome;

  /// 1-ativo; 0-inativo
  int ativo;

  /// ordem de aparição no menu
  int ordem;
  Tela({
    this.id = -1,
    required this.idmenu,
    required this.pasta,
    required this.nome,
    required this.ativo,
    required this.ordem,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'idtela': id,
      'idmenu': idmenu,
      'pasta': pasta,
      'nome': nome,
      'ativo': ativo,
      'ordem': ordem,
    };
    return map;
  }

  factory Tela.fromMap(Map<String, dynamic> map) {
    return Tela(
      id: map['idtela']?.toInt() ?? 0,
      idmenu: map['idmenu']?.toInt() ?? 0,
      pasta: map['pasta'] ?? '',
      nome: map['nome'] ?? '',
      ativo: map['ativo']?.toInt() ?? 0,
      ordem: map['ordem']?.toInt() ?? 0,
    );
  }
}
