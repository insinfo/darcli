import 'package:sibem_core/core.dart';

class UsuarioWeb implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'usuario_web';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int id;

  /// se foi confirmado poe e-mail
  int confirmado;

  bool get isConfirmado => confirmado == 1;

  /// quando foi confirmado poe e-mail
  DateTime? dataConfirmacao;
  DateTime dataCadastro;

  /// password
  String chave;
  String? repeteChave;

  /// login é o CPF ou CNPJ
  String login;

  String nome;
  String email;
  String? repeteEmail;

  /// empregador | candidato
  String tipo;

  String telefone;

  bool get isCandidato => tipo.toLowerCase() == 'candidato';
  bool get isEmpregador => tipo.toLowerCase() == 'empregador';
  // se true já fez o Pre-cadastro e ja esta validado
  bool? isValidado = false;

  /// fisica | juridica
  String tipoPessoa;

  /// não utilizado no momento
  int? idPessoa;

  UsuarioWeb(
      {required this.id,
      required this.confirmado,
      this.dataConfirmacao,
      required this.dataCadastro,
      required this.chave,
      required this.login,
      required this.nome,
      required this.email,
      required this.tipo,
      required this.telefone,
      this.isValidado = false,
      this.idPessoa,
      required this.tipoPessoa});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'confirmado': confirmado,
      'data_confirmacao': dataConfirmacao?.toIso8601String(),
      'data_cadastro': dataCadastro.toIso8601String(),
      'chave': chave,
      'login': login,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'telefone': telefone,
      'isValidado': isValidado,
      'tipoPessoa': tipoPessoa,
    };
    if (idPessoa != null) {
      map['idPessoa'] = idPessoa;
    }
    // if (tipoPessoa != null) {
    //   map['tipoPessoa'] = tipoPessoa;
    // }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    login = login.replaceAll(RegExp(r'[^0-9]'), '');
    return toMap()
      ..remove('id')
      ..remove('isValidado')
      ..remove('idPessoa');
  }

  Map<String, dynamic> toUpdateMap() {
    login = login.replaceAll(RegExp(r'[^0-9]'), '');
    return toMap()
      ..remove('id')
      ..remove('chave')
      ..remove('isValidado')
      ..remove('idPessoa');
  }

  factory UsuarioWeb.fromMap(Map<String, dynamic> map) {
    final user = UsuarioWeb(
      id: map['id'],
      confirmado: map['confirmado'] as int,
      dataConfirmacao: DateTime.tryParse(map['data_confirmacao'].toString()),
      dataCadastro: DateTime.parse(map['data_cadastro'].toString()),
      chave: map['chave'] as String,
      login: map['login'] as String,
      nome: map['nome'] as String,
      email: map['email'],
      tipo: map['tipo'],
      telefone: map['telefone'],
      isValidado: map['isValidado'],
      tipoPessoa: map['tipoPessoa'],
    );
    if (map.containsKey('idPessoa')) {
      user.idPessoa = map['idPessoa'];
    }
    // if (map.containsKey('tipoPessoa')) {
    //   user.tipoPessoa = map['tipoPessoa'];
    // }

    return user;
  }

  @override
  bool operator ==(covariant UsuarioWeb other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
