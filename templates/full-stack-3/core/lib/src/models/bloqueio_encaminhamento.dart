import 'package:sibem_core/core.dart';

enum TipoBloqueioEncaminhamento {
  bloqueioTemporario,
  bloqueioAutomatico,
  desbloqueio
}

extension TipoBloqueioEncaminhamentoExtension on TipoBloqueioEncaminhamento {
  String get asString {
    switch (this) {
      case TipoBloqueioEncaminhamento.bloqueioTemporario:
        return 'bloqueio Temporário';
      case TipoBloqueioEncaminhamento.bloqueioAutomatico:
        return 'bloqueio Automático';
      case TipoBloqueioEncaminhamento.desbloqueio:
        return 'desbloqueio';
    }
  }
}

//bloqueios_encaminhamentos
class BloqueioEncaminhamento implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'bloqueios_encaminhamentos';

  /// fully qualified table name 'bloqueios_encaminhamentos'
  static const String fqtn = '$schemaName.$tableName';

  /// fully qualified id column name
  static const String idFqCol = '$tableName.$idCol';
  static const String idCol = 'id';

  static const String idVagaCol = 'idVaga';
  static const String dataCol = 'data';
  static const String justificativaCol = 'justificativa';
  static const String acaoCol = 'acao';

  /// fully qualified idUsuarioResponsavel column name
  static const String idUsuarioResponsavelFqCol = '$tableName.$idUsuarioResponsavelCol';
  static const String idUsuarioResponsavelCol = 'idUsuarioResponsavel';

  int id;
  int idVaga;

  /// data da ação
  DateTime data;
  String justificativa;
  TipoBloqueioEncaminhamento acao;
  int idUsuarioResponsavel;

  String? usuarioResponsavel;

  BloqueioEncaminhamento({
    this.id = -1,
    required this.idVaga,
    required this.data,
    required this.justificativa,
    required this.acao,
    required this.idUsuarioResponsavel,
  });

  factory BloqueioEncaminhamento.invalid() {
    return BloqueioEncaminhamento(
      idVaga: -1,
      data: DateTime.now(),
      justificativa: '',
      acao: TipoBloqueioEncaminhamento.bloqueioTemporario,
      idUsuarioResponsavel: -1,
    );
  }

  factory BloqueioEncaminhamento.fromMap(Map<String, dynamic> map) {
    final blo = BloqueioEncaminhamento(
      id: map['id'],
      idVaga: map['idVaga'],
      data: map['data'] is DateTime ? map['data'] : DateTime.parse(map['data']),
      justificativa: map['justificativa'],
      acao: bloqueioEncaminhamentoFromString(map['acao']),
      idUsuarioResponsavel: map['idUsuarioResponsavel'],
    );

    if (map.containsKey('usuarioResponsavel')) {
      blo.usuarioResponsavel = map['usuarioResponsavel'];
    }

    return blo;
  }

  static TipoBloqueioEncaminhamento bloqueioEncaminhamentoFromString(
      String? val) {
    switch (val) {
      case 'bloqueio Temporário':
        return TipoBloqueioEncaminhamento.bloqueioTemporario;
      case 'bloqueio Automático':
        return TipoBloqueioEncaminhamento.bloqueioAutomatico;
      case 'desbloqueio':
        return TipoBloqueioEncaminhamento.desbloqueio;
      default:
        throw Exception('TipoBloqueioEncaminhamento inexistente');
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'idVaga': idVaga,
      'data': data.toIso8601String(),
      'justificativa': justificativa,
      'acao': acao.asString,
      'idUsuarioResponsavel': idUsuarioResponsavel,
    };
    if (usuarioResponsavel != null) {
      map['usuarioResponsavel'] = usuarioResponsavel;
    }
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('usuarioResponsavel');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('usuarioResponsavel');
  }
}
