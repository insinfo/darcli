import 'package:intl/intl.dart';
import 'package:new_sali_core/src/models/base_model.dart';

/// log
class Auditoria implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'auditoria';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int numCgm;
  int codAcao;
  DateTime timestamp;

  String get dataFormatada {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }

  bool? transacao;
  String objeto;

  String? nomCgm;
  String? username;
  String? nomModulo;
  String? nomFuncionalidade;
  String? nomAcao;

  Auditoria({
    required this.numCgm,
    required this.codAcao,
    required this.timestamp,
    this.transacao,
    required this.objeto,
  });

  Auditoria copyWith({
    int? numCgm,
    int? codAcao,
    DateTime? timestamp,
    bool? transacao,
    String? objeto,
  }) {
    return Auditoria(
      numCgm: numCgm ?? this.numCgm,
      codAcao: codAcao ?? this.codAcao,
      timestamp: timestamp ?? this.timestamp,
      transacao: transacao ?? this.transacao,
      objeto: objeto ?? this.objeto,
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'numcgm': numCgm,
      'cod_acao': codAcao,
      'timestamp': timestamp.toIso8601String(),
      'transacao': transacao,
      'objeto': objeto,
    };

    if (nomCgm != null) {
      map['nom_cgm'] = nomCgm;
    }
    if (username != null) {
      map['username'] = username;
    }
    if (nomModulo != null) {
      map['nom_modulo'] = nomModulo;
    }
    if (nomFuncionalidade != null) {
      map['nom_funcionalidade'] = nomFuncionalidade;
    }
    if (nomAcao != null) {
      map['nom_acao'] = nomAcao;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('nom_cgm')
      ..remove('username')
      ..remove('nom_modulo')
      ..remove('nom_funcionalidade')
      ..remove('nom_acao');
  }

  factory Auditoria.fromMap(Map<String, dynamic> map) {
    final au = Auditoria(
      numCgm: map['numcgm'] as int,
      codAcao: map['cod_acao'] as int,
      timestamp: DateTime.parse(map['timestamp']),
      transacao: map['transacao'],
      objeto: map['objeto'] as String,
    );
    if (map.containsKey('nom_cgm')) {
      au.nomCgm = map['nom_cgm'];
    }
    if (map.containsKey('username')) {
      au.username = map['username'];
    }
    if (map.containsKey('nom_modulo')) {
      au.nomModulo = map['nom_modulo'];
    }
    if (map.containsKey('nom_funcionalidade')) {
      au.nomFuncionalidade = map['nom_funcionalidade'];
    }
    if (map.containsKey('nom_acao')) {
      au.nomAcao = map['nom_acao'];
    }

    return au;
  }

  @override
  String toString() {
    return 'Auditoria(numcgm: $numCgm, cod_acao: $codAcao, timestamp: $timestamp, transacao: $transacao, objeto: $objeto)';
  }

  @override
  bool operator ==(covariant Auditoria other) {
    if (identical(this, other)) return true;

    return other.numCgm == numCgm &&
        other.codAcao == codAcao &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return numCgm.hashCode ^ codAcao.hashCode ^ timestamp.hashCode;
  }
}
