import 'package:esic_core/esic_core.dart';

class Usuario implements SerializeBase {
  int id;
  String nome;
  String login;

  /// I A
  String status;
  String matricula;
  String cpfUsuario;
  String chave;

  /// Identificador da secretaria padrão a que o usuário pertence
  int? idSecretaria;
  int? idUsuarioInclusao;
  int? idUsuarioAlteracao;
  DateTime? dataInclusao;
  DateTime? dataAlteracao;

  Usuario({
    required this.id,
    required this.nome,
    required this.login,
    required this.status,
    required this.matricula,
    required this.cpfUsuario,
    required this.chave,
    this.idSecretaria,
    this.idUsuarioInclusao,
    this.idUsuarioAlteracao,
    this.dataInclusao,
    this.dataAlteracao,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'idusuario': id,
      'nome': nome,
      'login': login,
      'status': status,
      'matricula': matricula,
      'cpfusuario': cpfUsuario,
      'chave': chave,
      'idsecretaria': idSecretaria,
      'idusuarioinclusao': idUsuarioInclusao,
      'idusuarioalteracao': idUsuarioAlteracao,
      'dataalteracao': dataAlteracao?.toString(),
    };
    if (dataInclusao != null) {
      map['datainclusao'] = dataInclusao?.toString();
    }
    if (dataAlteracao != null) {
      map['dataalteracao'] = dataAlteracao?.toString();
    }
    return map;
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('idusuario');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap()..remove('datainclusao');
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['idusuario']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      login: map['login'] ?? '',
      status: map['status'] ?? '',
      matricula: map['matricula'] ?? '',
      cpfUsuario: map['cpfusuario'] ?? '',
      chave: map['chave'] ?? '',
      idSecretaria: map['idsecretaria']?.toInt(),
      idUsuarioInclusao: map['idusuarioinclusao']?.toInt(),
      idUsuarioAlteracao: map['idusuarioalteracao']?.toInt(),
      dataInclusao: map['datainclusao'] != null
          ? DateTime.tryParse(map['datainclusao'].toString())
          : null,
      dataAlteracao: map['dataalteracao'] != null
          ? DateTime.tryParse(map['dataalteracao'].toString())
          : null,
    );
  }
}
