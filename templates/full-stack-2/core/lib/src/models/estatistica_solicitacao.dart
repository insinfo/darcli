import 'package:esic_core/esic_core.dart';

/// {
///   "ano": 2015,
///   "total": 7,
///   "respondidas": 7
/// },
class EstatisticaSolicitacao implements SerializeBase {
  int ano;
  int total;
  int? respondidas;
  EstatisticaSolicitacao({
    required this.ano,
    required this.total,
    this.respondidas = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'ano': ano,
      'total': total,
      'respondidas': respondidas,
    };
  }

  factory EstatisticaSolicitacao.fromMap(Map<String, dynamic> map) {
    return EstatisticaSolicitacao(
      ano: map['ano']?.toInt() ?? 0,
      total: map['total']?.toInt() ?? 0,
      respondidas: map['respondidas']?.toInt() ?? 0,
    );
  }
}
