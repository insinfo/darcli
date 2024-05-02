// ignore_for_file: public_member_api_docs, sort_constructors_first


import 'package:intl/intl.dart';
import 'package:new_sali_core/new_sali_core.dart';

/// Andamento de processo do Modulo Protocolo do Sali/Siamweb
class Andamento implements BaseModel {
  /// nome do esquema
  static const String schemaName = 'public';

  /// nome da tabela
  static const String tableName = 'sw_andamento';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  /// chave primaria
  int codAndamento;

  /// chave primaria
  int codProcesso;

  /// chave primaria
  String anoExercicio;

  int codOrgao;
  int codUnidade;
  int codDepartamento;
  int codSetor;

  /// Equivale ao ano Execicio do Orgão
  /// pois tanto setor/departamento/unidade usa o ano do orgão
  String anoExercicioSetor;

  int codUsuario;
  DateTime timestamp;

  //propriedades anexadas
  String? processo;
  DateTime? dataAndamento;

  String get dataAndamentoFormatada {
    return dataAndamento == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(dataAndamento!);
  }
  String? nomeCgmAndamento;
  String? nomeSetorDestino;

  DateTime? dataRecebimento;
  String get dataRecebimentoFormatada {
    return dataRecebimento == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(dataRecebimento!);
  }

  String? nomeCgmRecebimento;

  String? descricaoDespacho;
  int? codUsuarioDespacho;
  DateTime? dataDespacho;
  String? nomeCgmDespacho;
  String? nome_usuario_despacho;
  String? nome_usuario_andamento;
  String? nome_usuario_recebimento;

  /// Equivale ao anoExercicioSetor
  /// pois tanto setor/departamento/unidade usa o ano do orgão
  String? anoExercicioOrgao;

  List<Despacho> despachos = [];

  bool isUltimo = false;

  Andamento({
    required this.codAndamento,
    required this.codProcesso,
    required this.anoExercicio,
    required this.codOrgao,
    required this.codUnidade,
    required this.codDepartamento,
    required this.codSetor,
    required this.anoExercicioSetor,
    required this.codUsuario,
    required this.timestamp,
  });

  Andamento copyWith({
    int? codAndamento,
    int? codProcesso,
    String? anoExercicio,
    int? codOrgao,
    int? codUnidade,
    int? codDepartamento,
    int? codSetor,
    String? anoExercicioSetor,
    int? codUsuario,
    DateTime? timestamp,
  }) {
    return Andamento(
      codAndamento: codAndamento ?? this.codAndamento,
      codProcesso: codProcesso ?? this.codProcesso,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      codOrgao: codOrgao ?? this.codOrgao,
      codUnidade: codUnidade ?? this.codUnidade,
      codDepartamento: codDepartamento ?? this.codDepartamento,
      codSetor: codSetor ?? this.codSetor,
      anoExercicioSetor: anoExercicioSetor ?? this.anoExercicioSetor,
      codUsuario: codUsuario ?? this.codUsuario,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'cod_andamento': codAndamento,
      'cod_processo': codProcesso,
      'ano_exercicio': anoExercicio,
      'cod_orgao': codOrgao,
      'cod_unidade': codUnidade,
      'cod_departamento': codDepartamento,
      'cod_setor': codSetor,
      'ano_exercicio_setor': anoExercicioSetor,
      'cod_usuario': codUsuario,
      'timestamp': timestamp.toIso8601String(),
    };
    if (processo != null) {
      map['processo'] = processo;
    }
    if (dataAndamento != null) {
      map['data_andamento'] = dataAndamento?.toIso8601String();
    }
    if (nomeCgmAndamento != null) {
      map['nome_cgm_andamento'] = nomeCgmAndamento;
    }
    if (nomeSetorDestino != null) {
      map['nome_setor_destino'] = nomeSetorDestino;
    }
    if (dataRecebimento != null) {
      map['data_recebimento'] = dataRecebimento?.toIso8601String();
    }
    if (nomeCgmRecebimento != null) {
      map['nome_cgm_recebimento'] = nomeCgmRecebimento;
    }

    if (descricaoDespacho != null) {
      map['descricao_despacho'] = descricaoDespacho;
    }
    if (codUsuarioDespacho != null) {
      map['cod_usuario_despacho'] = codUsuarioDespacho;
    }
    if (dataDespacho != null) {
      map['data_despacho'] = dataDespacho;
    }
    if (nomeCgmDespacho != null) {
      map['nome_cgm_despacho'] = nomeCgmDespacho;
    }

    if (nome_usuario_despacho != null) {
      map['nome_usuario_despacho'] = nome_usuario_despacho;
    }
    if (nome_usuario_andamento != null) {
      map['nome_usuario_andamento'] = nome_usuario_andamento;
    }
    if (nome_usuario_recebimento != null) {
      map['nome_usuario_recebimento'] = nome_usuario_recebimento;
    }

    if (despachos.isNotEmpty) {
      map['despachos'] = despachos.map((e) => e.toMap()).toList();
    }

    if (anoExercicioOrgao != null) {
      map['ano_exercicio_orgao'] = anoExercicioOrgao;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('processo')
      ..remove('data_andamento')
      ..remove('nome_cgm_andamento')
      ..remove('nome_setor_destino')
      ..remove('data_recebimento')
      ..remove('nome_cgm_recebimento')
      ..remove('descricao_despacho')
      ..remove('cod_usuario_despacho')
      ..remove('data_despacho')
      ..remove('nome_usuario_despacho')
      ..remove('nome_usuario_andamento')
      ..remove('nome_usuario_recebimento')
      ..remove('despachos')
      ..remove('ano_exercicio_orgao')
      ..remove('nome_cgm_despacho');
  }

  Map<String, dynamic> toUpdateMap() {
    return toInsertMap();
  }

  factory Andamento.fromMap(Map<String, dynamic> map) {
    var anda = Andamento(
      codAndamento: map['cod_andamento'] as int,
      codProcesso: map['cod_processo'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      codOrgao: map['cod_orgao'] as int,
      codUnidade: map['cod_unidade'] as int,
      codDepartamento: map['cod_departamento'] as int,
      codSetor: map['cod_setor'] as int,
      anoExercicioSetor: map['ano_exercicio_setor'] as String,
      codUsuario: map['cod_usuario'] as int,
      timestamp: DateTime.parse(map['timestamp'].toString()),
    );
    if (map.containsKey('processo')) {
      anda.processo = map['processo'];
    }
    if (map.containsKey('data_andamento')) {
      anda.dataAndamento = DateTime.tryParse(map['data_andamento'].toString());
    }
    if (map.containsKey('nome_cgm_andamento')) {
      anda.nomeCgmAndamento = map['nome_cgm_andamento'];
    }
    if (map.containsKey('nome_setor_destino')) {
      anda.nomeSetorDestino = map['nome_setor_destino'];
    }
    //parte do recebimento
    if (map.containsKey('data_recebimento')) {
      anda.dataRecebimento =
          DateTime.tryParse(map['data_recebimento'].toString());
    }
    if (map.containsKey('nome_cgm_recebimento')) {
      anda.nomeCgmRecebimento = map['nome_cgm_recebimento'];
    }
    //parte do despacho
    if (map.containsKey('descricao_despacho')) {
      anda.descricaoDespacho = map['descricao_despacho'];
    }
    if (map.containsKey('cod_usuario_despacho')) {
      anda.codUsuarioDespacho = map['cod_usuario_despacho'];
    }
    if (map.containsKey('data_despacho')) {
      anda.dataDespacho = DateTime.tryParse(map['data_despacho'].toString());
    }
    if (map.containsKey('nome_cgm_despacho')) {
      anda.nomeCgmDespacho = map['nome_cgm_despacho'];
    }

    if (map.containsKey('nome_usuario_despacho')) {
      anda.nome_usuario_despacho = map['nome_usuario_despacho'];
    }
    if (map.containsKey('nome_usuario_andamento')) {
      anda.nome_usuario_andamento = map['nome_usuario_andamento'];
    }
    if (map.containsKey('nome_usuario_recebimento')) {
      anda.nome_usuario_recebimento = map['nome_usuario_recebimento'];
    }

    if (map.containsKey('ano_exercicio_orgao')) {
      anda.anoExercicioOrgao = map['ano_exercicio_orgao'];
    }

    if (map.containsKey('despachos')) {
      var desp = map['despachos'];
      if (desp is List<dynamic>) {
        anda.despachos = desp.map((e) => Despacho.fromMap(e)).toList();
      } else if (desp is List<Despacho>) {
        anda.despachos = desp;
      }
    }

    return anda;
  }

  @override
  String toString() {
    return 'Andamento(cod_andamento: $codAndamento, cod_processo: $codProcesso, ano_exercicio: $anoExercicio, cod_orgao: $codOrgao, cod_unidade: $codUnidade, cod_departamento: $codDepartamento, cod_setor: $codSetor, ano_exercicio_setor: $anoExercicioSetor, cod_usuario: $codUsuario, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant Andamento other) {
    if (identical(this, other)) return true;

    return other.codAndamento == codAndamento &&
        other.codProcesso == codProcesso &&
        other.anoExercicio == anoExercicio;
  }

  @override
  int get hashCode {
    return codAndamento.hashCode ^ codProcesso.hashCode ^ anoExercicio.hashCode;
  }
}
