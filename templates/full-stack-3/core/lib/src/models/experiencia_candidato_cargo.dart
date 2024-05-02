import 'package:sibem_core/core.dart';

//
class ExperienciaCandidatoCargo implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'experiencias_candidatos_cargos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// fully qualified id column name
  static const String idFqCol = '$tableName$idCol';
  static const String idCol = 'id';

  static const String idCandidatoFqCol = '$tableName.$idCandidatoCol';
  static const String idCandidatoCol = 'idCandidato';

  static const String experienciaFqCol = '$tableName.$experienciaCol';
  static const String experienciaCol = 'experiencia';

  static const String idCargoFqCol = '$tableName.$idCargoCol';
  static const String idCargoCol = 'idCargo';

  static const String tempoExperienciaFormalFqCol =
      '$tableName.$tempoExperienciaFormalCol';
  static const String tempoExperienciaFormalCol = 'tempoExperienciaFormal';

  static const String tempoExperienciaInformalFqCol =
      '$tableName.$tempoExperienciaInformalCol';
  static const String tempoExperienciaInformalCol = 'tempoExperienciaInformal';

  static const String tempoExperienciaMeiFqCol =
      '$tableName.$tempoExperienciaMeiCol';
  static const String tempoExperienciaMeiCol = 'tempoExperienciaMei';

  static const String breveDescricaoFqCol = '$tableName.$breveDescricaoCol';
  static const String breveDescricaoCol = 'breveDescricao';

  int id;
  int idCandidato;
  int idCargo;

  /// tempo de experiencia em meses com CTPS
  int? tempoExperienciaFormal;
  int? tempoExperienciaInformal;
  int? tempoExperienciaMei;
  bool? experiencia;

  String? breveDescricao;

  /// propriedade anexada
  String? nomeCargo;

  ExperienciaCandidatoCargo({
    this.id = -1,
    required this.idCandidato,
    required this.idCargo,
    this.tempoExperienciaFormal,
    this.tempoExperienciaInformal,
    this.tempoExperienciaMei,
    this.breveDescricao,
    this.nomeCargo,
    this.experiencia,
  });

  factory ExperienciaCandidatoCargo.fromMap(Map<String, dynamic> map) {
    final exp = ExperienciaCandidatoCargo(
      id: map['id'],
      idCandidato: map['idCandidato'],
      idCargo: map['idCargo'],
      tempoExperienciaFormal: map['tempoExperienciaFormal'],
      tempoExperienciaInformal: map['tempoExperienciaInformal'],
      tempoExperienciaMei: map['tempoExperienciaMei'],
      breveDescricao: map['breveDescricao'],
      nomeCargo: map['nomeCargo'],
      experiencia: map['experiencia'],
    );
    return exp;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'idCandidato': idCandidato,
      'idCargo': idCargo,
      'tempoExperienciaFormal': tempoExperienciaFormal,
      'tempoExperienciaInformal': tempoExperienciaInformal,
      'tempoExperienciaMei': tempoExperienciaMei,
      'breveDescricao': breveDescricao,
      'nomeCargo': nomeCargo,
      'experiencia': experiencia,
    };
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('nomeCargo');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('nomeCargo');
  }
}
