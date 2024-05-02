// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:new_sali_core/src/models/base_model.dart';

class UltimoAndamento implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_ultimo_andamento';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  /// chave primaria char
  String anoExercicio;

  /// chave int4
  int codProcesso;
  int codAndamento;
  int codOrgao;
  int codUnidade;
  int codDepartamento;
  int codSetor;
  String anoExercicioSetor;

  /// CGM do usuario
  int codUsuario;
  DateTime timestamp;

  UltimoAndamento({
    required this.anoExercicio,
    required this.codProcesso,
    required this.codAndamento,
    required this.codOrgao,
    required this.codUnidade,
    required this.codDepartamento,
    required this.codSetor,
    required this.anoExercicioSetor,
    required this.codUsuario,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ano_exercicio': anoExercicio,
      'cod_processo': codProcesso,
      'cod_andamento': codAndamento,
      'cod_orgao': codOrgao,
      'cod_unidade': codUnidade,
      'cod_departamento': codDepartamento,
      'cod_setor': codSetor,
      'ano_exercicio_setor': anoExercicioSetor,
      'cod_usuario': codUsuario,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UltimoAndamento.fromMap(Map<String, dynamic> map) {
    return UltimoAndamento(
      anoExercicio: map['ano_exercicio'] as String,
      codProcesso: map['cod_processo'] as int,
      codAndamento: map['cod_andamento'] as int,
      codOrgao: map['cod_orgao'] as int,
      codUnidade: map['cod_unidade'] as int,
      codDepartamento: map['cod_departamento'] as int,
      codSetor: map['cod_setor'] as int,
      anoExercicioSetor: map['ano_exercicio_setor'] as String,
      codUsuario: map['cod_usuario'] as int,
      timestamp: DateTime.parse(map['timestamp'].toString()),
    );
  }
}
