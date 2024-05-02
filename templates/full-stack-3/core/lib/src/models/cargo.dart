import 'package:sibem_core/core.dart';

class Cargo implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'cargos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idCol = 'id';
  static const String idFqCol = '$tableName.$idCol';

  static const String nameCol = 'nome';
  static const String nameFqCol = '$tableName.$nameCol';

  /// Obrigatorio
  int id;

  /// Obrigatorio
  String nome;

  // propriedades anexadas
  DateTime? dataCadastro;
  bool? experiencia;

  /// propriedade anexada da tabela experiencias_candidatos_cargos
  int? tempoExperienciaInformal;

  /// propriedade anexada da tabela experiencias_candidatos_cargos
  int? tempoExperienciaFormal;

  /// propriedade anexada da tabela experiencias_candidatos_cargos
  int? tempoExperienciaMei;

  /// propriedade anexada da tabela experiencias_candidatos_cargos
  String? breveDescricao;

  /// para tabela cargos_desejados
  int? idCandidato;

  Cargo({
    this.id = -1,
    required this.nome,
    this.dataCadastro,
    this.experiencia,
    this.tempoExperienciaFormal,
    this.tempoExperienciaInformal,
    this.tempoExperienciaMei,
    this.breveDescricao,
    
  });

  factory Cargo.fromMap(Map<String, dynamic> map) {
    final ca = Cargo(
      id: map['id'],
      nome: map['nome'],
    );

    if (map.containsKey('dataCadastro')) {
      ca.dataCadastro = map['dataCadastro'] is DateTime
          ? map['dataCadastro']
          : DateTime.tryParse(map['dataCadastro'].toString());
    }

    if (map.containsKey('experiencia')) {
      ca.experiencia = map['experiencia'];
    }

    if (map.containsKey('tempoExperienciaFormal')) {
      ca.tempoExperienciaFormal = map['tempoExperienciaFormal'];
    }

    if (map.containsKey('tempoExperienciaInformal')) {
      ca.tempoExperienciaInformal = map['tempoExperienciaInformal'];
    }

    if (map.containsKey('tempoExperienciaMei')) {
      ca.tempoExperienciaMei = map['tempoExperienciaMei'];
    }
    if (map.containsKey('breveDescricao')) {
      ca.breveDescricao = map['breveDescricao'];
    }

    return ca;
  }

  /// para tabela experiencia_candidato_cargo que liga cargos desejados com Candidato
  Map<String, dynamic> toInsertExperienciaCandidatoCargo() {
    return {
      'idCandidato': idCandidato,
      'idCargo': id,
      'tempoExperienciaInformal': tempoExperienciaInformal,
      'tempoExperienciaFormal': tempoExperienciaFormal,
      'tempoExperienciaMei': tempoExperienciaMei,
      'breveDescricao': breveDescricao,
      'experiencia': experiencia,
    };
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'nome': nome,
    };
    if (dataCadastro != null) {
      map['dataCadastro'] = dataCadastro?.toString();
    }
    if (experiencia != null) {
      map['experiencia'] = experiencia;
    }

    if (tempoExperienciaFormal != null) {
      map['tempoExperienciaFormal'] = tempoExperienciaFormal;
    }

    if (tempoExperienciaInformal != null) {
      map['tempoExperienciaInformal'] = tempoExperienciaInformal;
    }

    if (tempoExperienciaMei != null) {
      map['tempoExperienciaMei'] = tempoExperienciaMei;
    }
    if (breveDescricao != null) {
      map['breveDescricao'] = breveDescricao;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('dataCadastro')
      ..remove('experiencia')
      ..remove('tempoExperienciaFormal')  
      ..remove('tempoExperienciaInformal')
      ..remove('tempoExperienciaMei')
      ..remove('breveDescricao');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('dataCadastro')
      ..remove('experiencia')
      ..remove('tempoExperienciaFormal')      
      ..remove('tempoExperienciaInformal')
      ..remove('tempoExperienciaMei')
      ..remove('breveDescricao');
  }
}
