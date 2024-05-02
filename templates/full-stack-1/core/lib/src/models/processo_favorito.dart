import 'package:new_sali_core/new_sali_core.dart';

class ProcessoFavorito implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_processos_favoritos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;
  int codProcesso;
  String anoExercicio;
  int numCgm;
  DateTime dataCadastro;
  String? descricao;

  /// propriedade anexada
  String? nomAssunto;

  ProcessoFavorito({
    required this.id,
    required this.codProcesso,
    required this.anoExercicio,
    required this.numCgm,
    required this.dataCadastro,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'cod_processo': codProcesso,
      'ano_exercicio': anoExercicio,
      'numcgm': numCgm,
      'data_cadastro': dataCadastro.toIso8601String(),
    };

    if (descricao != null) {
      map['descricao'] = descricao;
    }

    if (nomAssunto != null) {
      map['nom_assunto'] = nomAssunto;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    dataCadastro = DateTime.now();
    return toMap()
      ..remove('id')
      ..remove('nom_assunto');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('dataCadastro')
      ..remove('nom_assunto');
  }

  factory ProcessoFavorito.fromMap(Map<String, dynamic> map) {
    var procFav = ProcessoFavorito(
      id: map['id'] as int,
      codProcesso: map['cod_processo'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      numCgm: map['numcgm'] as int,
      dataCadastro: DateTime.parse(map['data_cadastro']),
    );
    if (map.containsKey('nom_assunto')) {
      procFav.nomAssunto = map['nom_assunto'];
    }
    if (map.containsKey('descricao')) {
      procFav.descricao = map['descricao'];
    }

    return procFav;
  }
}
