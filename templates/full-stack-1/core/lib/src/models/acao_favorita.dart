import 'package:new_sali_core/new_sali_core.dart';

class AcaoFavorita implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_acoes_favoritas';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  int id;
  int numCgm;
  int codAcao;
  DateTime dataCadastro;
  String? descricao;

  String? nomAcao;

  AcaoFavorita({
    required this.id,
    required this.numCgm,
    required this.codAcao,
    required this.dataCadastro,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'numcgm': numCgm,
      'cod_acao': codAcao,
      'data_cadastro': dataCadastro.toIso8601String(),
      'descricao': descricao,
    };
    if (nomAcao != null) {
      map['nom_acao'] = nomAcao;
    }
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    dataCadastro = DateTime.now();
    return toMap()
      ..remove('nom_acao')
      ..remove('id');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('nom_acao')
      ..remove('id')
      ..remove('data_cadastro');
  }

  factory AcaoFavorita.fromMap(Map<String, dynamic> map) {
    var acaoFavorita = AcaoFavorita(
      id: map['id'] as int,
      numCgm: map['numcgm'] as int,
      codAcao: map['cod_acao'] as int,
      dataCadastro: DateTime.parse(map['data_cadastro']),
      descricao: map['descricao'] != null ? map['descricao'] as String : null,
    );

    if (map.containsKey('nom_acao')) {
      acaoFavorita.nomAcao = map['nom_acao'];
    }

    return acaoFavorita;
  }

  @override
  String toString() {
    return 'AcaoFavorita(id: $id, numcgm: $numCgm, cod_acao: $codAcao, data_cadastro: $dataCadastro, descricao: $descricao)';
  }

  @override
  bool operator ==(covariant AcaoFavorita other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
