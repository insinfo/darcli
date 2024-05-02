import 'package:esic_core/esic_core.dart';

class TipoSolicitacao implements SerializeBase {
  /// idtiposolicitacao
  int id;
  String nome;

  /// Identificador do tipo de solicitação que é feita após essa.
  int? idTipoSolicitacaoSeguinte;

  /// I-inicial; S-seguimento; U-ultima
  String instancia;
  int idUsuarioInclusao;
  DateTime dataInclusao;
  int? idUsuarioAlteracao;
  DateTime? dataAlteracao;

  TipoSolicitacao({
    this.id = -1,
    required this.nome,
    this.idTipoSolicitacaoSeguinte,
    required this.instancia,
    required this.idUsuarioInclusao,
    required this.dataInclusao,
    this.idUsuarioAlteracao,
    this.dataAlteracao,
  });

  factory TipoSolicitacao.inicial() {
    return TipoSolicitacao(
      nome: 'Inicial',
      id: 1,
      idTipoSolicitacaoSeguinte: 2,
      instancia: '1',
      dataInclusao: DateTime(2014, 9, 11, 16, 12, 41),
      idUsuarioInclusao: 16,
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'idtiposolicitacao': id,
      'nome': nome,
      'idtiposolicitacao_seguinte': idTipoSolicitacaoSeguinte,
      'instancia': instancia,
      'idusuarioinclusao': idUsuarioInclusao,
      'datainclusao': dataInclusao.toString(),
      'idusuarioalteracao': idUsuarioAlteracao,
    };
    if (dataAlteracao != null) {
      map['dataalteracao'] = dataAlteracao.toString();
    }
    return map;
  }

  Map<String, dynamic> toDbInsert() {
    return toMap()..remove('idtiposolicitacao');
  }

  Map<String, dynamic> toDbUpdate() {
    return toMap();
  }

  factory TipoSolicitacao.fromMap(Map<String, dynamic> map) {
    return TipoSolicitacao(
      id: map['idtiposolicitacao']?.toInt() ?? 0,
      nome: map['nome'] ?? '',
      idTipoSolicitacaoSeguinte: map['idtiposolicitacao_seguinte']?.toInt(),
      instancia: map['instancia'] ?? '',
      idUsuarioInclusao: map['idusuarioinclusao']?.toInt() ?? 0,
      dataInclusao: DateTime.parse(map['datainclusao']),
      idUsuarioAlteracao: map['idusuarioalteracao']?.toInt(),
      dataAlteracao: map['dataalteracao'] != null
          ? DateTime.tryParse(map['dataalteracao'])
          : null,
    );
  }
}
