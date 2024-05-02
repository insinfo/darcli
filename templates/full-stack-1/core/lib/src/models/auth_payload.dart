// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/src/models/base_model.dart';

/// dados enviados para o frontend apos autenticação
/// TokenData
class AuthPayload implements BaseModel {
  /// cod_usuario
  int numCgm;
  String? cpf;
  String nomCgm;
  String username;

  /// anoExercicio do login do usuario
  String anoExercicio;

  int codSetor;
  int idSetor;
  String anoExercicioSetor;
  int codOrgao;
  int codUnidade;
  int codDepartamento;
  String? nomSetor;
  DateTime expiry;
  String accessToken;

  int get codUsuario => numCgm;

  AuthPayload({
    required this.numCgm,
    this.cpf,
    required this.nomCgm,
    required this.username,
    required this.anoExercicio,
    required this.codSetor,
    required this.idSetor,
    required this.anoExercicioSetor,
    required this.codOrgao,
    required this.codUnidade,
    required this.codDepartamento,
    required this.nomSetor,
    required this.expiry,
    this.accessToken = '',
  });

  AuthPayload copyWith(
      {int? numCgm,
      String? cpf,
      String? nomCgm,
      String? username,
      String? anoExercicio,
      int? codSetor,
      int? idSetor,
      int? codOrgao,
      int? codUnidade,
      int? codDepartamento,
      String? nomSetor,
      DateTime? expiry,
      String? anoExercicioSetor}) {
    return AuthPayload(
      expiry: expiry ?? this.expiry,
      numCgm: numCgm ?? this.numCgm,
      cpf: cpf ?? this.cpf,
      nomCgm: nomCgm ?? this.nomCgm,
      anoExercicio: anoExercicio ?? this.anoExercicio,
      username: username ?? this.username,
      codSetor: codSetor ?? this.codSetor,
      idSetor: idSetor ?? this.idSetor,
      codOrgao: codOrgao ?? this.codOrgao,
      codUnidade: codUnidade ?? this.codUnidade,
      codDepartamento: codDepartamento ?? this.codDepartamento,
      nomSetor: nomSetor,
      anoExercicioSetor: anoExercicioSetor ?? this.anoExercicioSetor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'numcgm': numCgm,
      'cpf': cpf,
      'nom_cgm': nomCgm,
      'username': username,
      'ano_exercicio': anoExercicio,
      'cod_setor': codSetor,
      'id_setor': idSetor,
      'cod_orgao': codOrgao,
      'cod_unidade': codUnidade,
      'cod_departamento': codDepartamento,
      'nom_setor': nomSetor,
      'expiry': expiry.toIso8601String(),
      'ano_exercicio_setor': anoExercicioSetor,
      'accessToken': accessToken,
    };
  }

  factory AuthPayload.fromMap(Map<String, dynamic> map) {
    final authPayload = AuthPayload(
      numCgm: map['numcgm'] as int,
      cpf: map['cpf'] != null ? map['cpf'] as String : null,
      nomCgm: map['nom_cgm'] as String,
      username: map['username'] as String,
      anoExercicio: map['ano_exercicio'] as String,
      codSetor: map['cod_setor'],
      idSetor: map['id_setor'],
      codOrgao: map['cod_orgao'],
      codUnidade: map['cod_unidade'],
      codDepartamento: map['cod_departamento'],
      nomSetor: map['nom_setor'],
      expiry: map['expiry'] is DateTime
          ? map['expiry']
          : DateTime.parse(map['expiry']),
      anoExercicioSetor: map['ano_exercicio_setor'],
    );
    if (map.containsKey('accessToken')) {
      authPayload.accessToken = map['accessToken'];
    }
    return authPayload;
  }

  String toJson() => json.encode(toMap());

  factory AuthPayload.fromJson(String source) =>
      AuthPayload.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AuthPayload(numcgm: $numCgm, cpf: $cpf, nom_cgm: $nomCgm, username: $username)';
  }

  @override
  bool operator ==(covariant AuthPayload other) {
    if (identical(this, other)) return true;

    return other.numCgm == numCgm;
  }

  @override
  int get hashCode {
    return numCgm.hashCode;
  }
}
