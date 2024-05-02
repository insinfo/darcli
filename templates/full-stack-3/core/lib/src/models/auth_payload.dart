import 'dart:convert';

import 'package:sibem_core/core.dart';

/// dados enviados para o frontend apos autenticação
/// TokenData do Sibem site
class AuthPayload implements SerializeBase {
  /// cod_usuario
  int idUsuario;
  String tipo;
  String nome;
  String login;
  DateTime expiry;
  String accessToken;
  String? email;

  bool get isCandidato => tipo == 'Candidato';

  bool get isEmpregador => tipo == 'Empregador';
// se true já fez o Pre-cadastro e ja esta validado
  bool? isValidado = false;

  bool? jaCadastrado = false;

  /// pessoa jubarte/pmroPadrao
  int? idPessoa;

  /// para saber se o cadastro ja venceu
  CandidatoStatus? candidatoStatus;

  AuthPayload({
    required this.idUsuario,
    required this.tipo,
    required this.nome,
    required this.login,
    required this.expiry,
    this.accessToken = '',
    this.isValidado = false,
    this.email,
    this.jaCadastrado = false,
    this.idPessoa,
    this.candidatoStatus,
  });

  factory AuthPayload.invalid() {
    return AuthPayload(
        expiry: DateTime.now().add(Duration(hours: 1)),
        idUsuario: -1,
        nome: '',
        login: '',
        tipo: '',
        isValidado: false,
        jaCadastrado: false);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idUsuario': idUsuario,
      'tipo': tipo,
      'nome': nome,
      'login': login,
      'expiry': expiry.toIso8601String(),
      'accessToken': accessToken,
    };
    if (isValidado != null) {
      map['isValidado'] = isValidado;
    }
    if (jaCadastrado != null) {
      map['jaCadastrado'] = jaCadastrado;
    }
    if (email != null) {
      map['email'] = email;
    }
    if (idPessoa != null) {
      map['idPessoa'] = idPessoa;
    }
    if (candidatoStatus != null) {
      map['candidatoStatus'] = candidatoStatus!.value;
    }

    return map;
  }

  factory AuthPayload.fromMap(Map<String, dynamic> map) {
    final authPayload = AuthPayload(
      idUsuario: map['idUsuario'] as int,
      tipo: map['tipo'],
      nome: map['nome'] as String,
      login: map['login'] as String,
      expiry: map['expiry'] is DateTime
          ? map['expiry']
          : DateTime.parse(map['expiry']),
    );
    if (map.containsKey('accessToken')) {
      authPayload.accessToken = map['accessToken'];
    }
    if (map.containsKey('isValidado')) {
      authPayload.isValidado = map['isValidado'];
    }
    if (map.containsKey('jaCadastrado')) {
      authPayload.jaCadastrado = map['jaCadastrado'];
    }

    if (map.containsKey('email')) {
      authPayload.email = map['email'];
    }

    if (map.containsKey('idPessoa')) {
      authPayload.idPessoa = map['idPessoa'];
    }
    if (map.containsKey('candidatoStatus')) {
      authPayload.candidatoStatus = map['candidatoStatus'] is CandidatoStatus
          ? map['candidatoStatus']
          : CandidatoStatus.fromString(map['candidatoStatus']);
    }

    return authPayload;
  }

  String toJson() => json.encode(toMap());

  factory AuthPayload.fromJson(String source) =>
      AuthPayload.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant AuthPayload other) {
    if (identical(this, other)) return true;

    return other.idUsuario == idUsuario;
  }

  @override
  int get hashCode {
    return idUsuario.hashCode;
  }
}
