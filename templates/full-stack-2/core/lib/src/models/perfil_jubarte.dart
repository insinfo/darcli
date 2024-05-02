class PerfilJubarte {
  int id;
  int idSistema;
  String sigla;
  String descricao;
  int prioridade;
  bool ativo;
  PerfilJubarte({
    required this.id,
    required this.idSistema,
    required this.sigla,
    required this.descricao,
    required this.prioridade,
    required this.ativo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idSistema': idSistema,
      'sigla': sigla,
      'descricao': descricao,
      'prioridade': prioridade,
      'ativo': ativo,
    };
  }

  factory PerfilJubarte.fromMap(Map<String, dynamic> map) {
    return PerfilJubarte(
      id: map['id'],
      idSistema: map['idSistema'],
      sigla: map['sigla'],
      descricao: map['descricao'],
      prioridade: map['prioridade'],
      ativo: map['ativo'],
    );
  }
}
