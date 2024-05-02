// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:intl/intl.dart';
import 'package:new_sali_core/new_sali_core.dart';

class FiltroDespacho {
  /// cod_ultimo_andamento
  int? codAndamento;

  int codProcesso;
  String anoExercicio;

  FiltroDespacho({
    this.codAndamento,
    required this.codProcesso,
    required this.anoExercicio,
  });
}

class Despacho implements BaseModel {
  static const String schemaName = 'public';
  static const String tableName = 'sw_despacho';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// cod_ultimo_andamento de um processo
  int? codAndamento;

  int codProcesso;
  String anoExercicio;
  int codUsuario;

  /// texto do despacho de um andamento/tramite de processo
  String descricao;

  /// data e hora do despacho
  DateTime timestamp;

  String get dataDespachoFormatada {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }

  /// propriedade anexada
  String? nomeCgmDespacho;

  /// propriedade anexada
  String? nomeUsuarioDespacho;

  /// propriedade anexada para uso no despacho de multiplos processos
  /// representa processos que recebem o mesmo despacho
  List<CodigoProcesso> processos = [];

  Despacho({
    required this.codAndamento,
    required this.codProcesso,
    required this.anoExercicio,
    required this.codUsuario,
    required this.descricao,
    required this.timestamp,
  });

  Despacho copyWith({
    int? codAndamento,
    int? codProcesso,
    String? anoExercicio,
    int? codUsuario,
    String? descricao,
    DateTime? timestamp,
  }) {
    return Despacho(
      codAndamento: codAndamento ?? this.codAndamento,
      codProcesso: codProcesso ?? this.codProcesso,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      codUsuario: codUsuario ?? this.codUsuario,
      descricao: descricao ?? this.descricao,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('nome_usuario_despacho')
      ..remove('nome_cgm_despacho')
      ..remove('processos');
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_andamento': codAndamento,
      'cod_processo': codProcesso,
      'ano_exercicio': anoExercicio,
      'cod_usuario': codUsuario,
      'descricao': descricao,
      'timestamp': timestamp.toIso8601String(),
    };

    if (nomeCgmDespacho != null) {
      map['nome_cgm_despacho'] = nomeCgmDespacho;
    }
    if (nomeUsuarioDespacho != null) {
      map['nome_usuario_despacho'] = nomeUsuarioDespacho;
    }

    if (processos.isNotEmpty) {
      map['processos'] = processos.map((e) => e.toMap()).toList();
    }

    return map;
  }

  factory Despacho.fromMap(Map<String, dynamic> map) {
    var despacho = Despacho(
      codAndamento: map['cod_andamento'] as int,
      codProcesso: map['cod_processo'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      codUsuario: map['cod_usuario'] as int,
      descricao: map['descricao'] as String,
      timestamp: DateTime.parse(map['timestamp'].toString()),
    );

    if (map.containsKey('nome_cgm_despacho')) {
      despacho.nomeCgmDespacho = map['nome_cgm_despacho'];
    }
    if (map.containsKey('nome_usuario_despacho')) {
      despacho.nomeUsuarioDespacho = map['nome_usuario_despacho'];
    }
    if (map.containsKey('processos')) {
      if (map['processos'] is List<CodigoProcesso>) {
        despacho.processos = map['processos'];
      } else {
        despacho.processos = (map['processos'] as List)
            .map((e) => CodigoProcesso.fromMap(e))
            .toList();
      }
    }
    return despacho;
  }

  @override
  String toString() {
    return 'Despacho(cod_andamento: $codAndamento, cod_processo: $codProcesso, ano_exercicio: $anoExercicio, cod_usuario: $codUsuario, descricao: $descricao, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant Despacho other) {
    if (identical(this, other)) return true;

    return other.codAndamento == codAndamento &&
        other.codProcesso == codProcesso &&
        other.anoExercicio == anoExercicio &&
        other.codUsuario == codUsuario;
  }

  @override
  int get hashCode {
    return codAndamento.hashCode ^
        codProcesso.hashCode ^
        anoExercicio.hashCode ^
        codUsuario.hashCode;
  }
}
