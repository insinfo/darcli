import 'package:esic_core/esic_core.dart';

class Secretaria implements SerializeBase {
  int id;
  String nome;
  String sigla;
  String? responsavel;
  String? telefoneContato;
  int ativado;

  /// Email do SIC do orgao (ou alias do grupo que faz parte do SIC do orgao)
  String? emailSic;

  /// indica se o SIC (lei de acesso) é unidade centralizadora (recebe as primeiras solicitações)
  int sicCentral;
  int? idUsuarioInclusao;
  int? idUsuarioAlteracao;
  DateTime? dataInclusao;
  DateTime? dataAlteracao;

  Secretaria({
    this.id = -1,
    required this.nome,
    required this.sigla,
    this.responsavel,
    this.telefoneContato,
    required this.ativado,
    this.emailSic,
    required this.sicCentral,
    this.idUsuarioInclusao,
    this.idUsuarioAlteracao,
    this.dataInclusao,
    this.dataAlteracao,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'idsecretaria': id,
      'nome': nome,
      'sigla': sigla,
      'responsavel': responsavel,
      'telefonecontato': telefoneContato,
      'ativado': ativado,
      'emailsic': emailSic,
      'siccentral': sicCentral,
      'idusuarioinclusao': idUsuarioInclusao,
      'idusuarioalteracao': idUsuarioAlteracao,
    };
    if (dataInclusao != null) {
      map['datainclusao'] = dataInclusao.toString();
    }

    if (dataAlteracao != null) {
      map['dataalteracao'] = dataAlteracao.toString();
    }
    return map;
  }

  factory Secretaria.fromMap(Map<String, dynamic> map) {
    return Secretaria(
      id: map['idsecretaria']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      sigla: map['sigla'] ?? '',
      responsavel: map['responsavel'],
      telefoneContato: map['telefonecontato'],
      ativado: map['ativado']?.toInt() ?? 0,
      emailSic: map['emailsic'],
      sicCentral: map['siccentral']?.toInt() ?? 0,
      idUsuarioInclusao: map['idusuarioinclusao']?.toInt(),
      idUsuarioAlteracao: map['idusuarioalteracao']?.toInt(),
      dataInclusao: map['datainclusao'] != null
          ? DateTime.tryParse(map['datainclusao'])
          : null,
      dataAlteracao: map['dataalteracao'] != null
          ? DateTime.tryParse(map['dataalteracao'])
          : null,
    );
  }
}
