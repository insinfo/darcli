// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:new_sali_core/new_sali_core.dart';

import 'base_model.dart';

class Usuario implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'usuario';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  int numCgm;
  int codOrgao;
  int codUnidade;
  int codDepartamento;
  int codSetor;

  /// ano exercicio do setor
  String anoExercicio;
  DateTime dtCadastro;
  String username;
  String password;

  /// A | I
  String status;

  String? nomCgm;

  String? nomDepartamento;
  String? nomOrgao;
  String? nomSetor;
  String? nomUnidade;

  /// propriedade anexada
  String repeatPassword = '';

  Usuario({
    required this.numCgm,
    required this.codOrgao,
    required this.codUnidade,
    required this.codDepartamento,
    required this.codSetor,
    required this.anoExercicio,
    required this.dtCadastro,
    required this.username,
    required this.password,
    required this.status,
  });

  /// cria uma nova instancia da class Usuario preenchido com dados inválidos para serem usados no formulário de cadastro de usuário
  factory Usuario.invalid() {
    return Usuario(
        numCgm: -1,
        codOrgao: -1,
        codUnidade: -1,
        codDepartamento: -1,
        codSetor: -1,
        anoExercicio: DateTime.now().year.toString(),
        dtCadastro: DateTime.now(),
        username: '',
        password: '',
        status: 'A');
  }

  Usuario copyWith({
    int? numCgm,
    int? codOrgao,
    int? codUnidade,
    int? codDepartamento,
    int? codSetor,
    String? anoExercicio,
    DateTime? dtCadastro,
    String? username,
    String? password,
    String? status,
  }) {
    return Usuario(
      numCgm: numCgm ?? this.numCgm,
      codOrgao: codOrgao ?? this.codOrgao,
      codUnidade: codUnidade ?? this.codUnidade,
      codDepartamento: codDepartamento ?? this.codDepartamento,
      codSetor: codSetor ?? this.codSetor,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      dtCadastro: dtCadastro ?? this.dtCadastro,
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'numcgm': numCgm,
      'cod_orgao': codOrgao,
      'cod_unidade': codUnidade,
      'cod_departamento': codDepartamento,
      'cod_setor': codSetor,
      'ano_exercicio': anoExercicio,
      'dt_cadastro': dtCadastro.toIso8601String(),
      'username': username,
      'password': password,
      'status': status,
    };
    if (nomCgm != null) {
      map['nom_cgm'] = nomCgm;
    }
    if (nomDepartamento != null) {
      map['nom_departamento'] = nomDepartamento;
    }
    if (nomOrgao != null) {
      map['nom_orgao'] = nomOrgao;
    }
    if (nomSetor != null) {
      map['nom_setor'] = nomSetor;
    }
    if (nomUnidade != null) {
      map['nom_unidade'] = nomUnidade;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map['password'] = '';
    map.remove('nom_cgm');
    map.remove('nom_departamento');
    map.remove('nom_orgao');
    map.remove('nom_setor');
    map.remove('nom_unidade');

    return map;
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('password')
      ..remove('numcgm')
      ..remove('dt_cadastro')
      ..remove('nom_cgm')
      ..remove('nom_departamento')
      ..remove('nom_orgao')
      ..remove('nom_setor')
      ..remove('nom_unidade');
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    final user = Usuario(
      numCgm: map['numcgm'] as int,
      codOrgao: map['cod_orgao'] as int,
      codUnidade: map['cod_unidade'] as int,
      codDepartamento: map['cod_departamento'] as int,
      codSetor: map['cod_setor'] as int,
      anoExercicio: map['ano_exercicio'] as String,
      dtCadastro: map['dt_cadastro'] is String
          ? DateTime.parse(map['dt_cadastro'])
          : map['dt_cadastro'],
      username: map['username'] as String,
      password: map['password'] as String,
      status: map['status'] as String,
    );

    if (map.containsKey('nom_cgm')) {
      user.nomCgm = map['nom_cgm'];
    }
    if (map.containsKey('nom_departamento')) {
      user.nomDepartamento = map['nom_departamento'];
    }
    if (map.containsKey('nom_orgao')) {
      user.nomOrgao = map['nom_orgao'];
    }
    if (map.containsKey('nom_setor')) {
      user.nomSetor = map['nom_setor'];
    }
    if (map.containsKey('nom_unidade')) {
      user.nomUnidade = map['nom_unidade'];
    }

    return user;
  }

  @override
  String toString() {
    return 'Usuario(numcgm: $numCgm, cod_orgao: $codOrgao, cod_unidade: $codUnidade, cod_departamento: $codDepartamento, cod_setor: $codSetor, ano_exercicio: $anoExercicio, dt_cadastro: $dtCadastro, username: $username, password: $password, status: $status)';
  }

  @override
  bool operator ==(covariant Usuario other) {
    if (identical(this, other)) return true;
    return other.numCgm == numCgm;
  }

  @override
  int get hashCode {
    return numCgm.hashCode;
  }
}
