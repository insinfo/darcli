import 'package:sibem_core/core.dart';

/// vagas_beneficios
class Beneficio implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'vagas_beneficios';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String idFqCol = '$tableName.$idCol';
  static const String idCol = 'id';

  static const String idVagaFqCol = '$tableName.$idVagaCol';
  static const String idVagaCol = 'idVaga';

  int id;
  int? idVaga;
  String nome;

  /// propriedade  vagas_beneficios
  String? valor;

  /// propriedade  vagas_beneficios
  String? observacao;

  bool check = false;

  Beneficio({
    this.id = -1,
    required this.idVaga,
    this.observacao,
    this.valor,
    required this.nome,
    check = false,
  });

  factory Beneficio.fromMap(Map<String, dynamic> map) {
    return Beneficio(
      id: map['id'],
      idVaga: map['idVaga'],
      valor: map['valor'],
      observacao: map['observacao'],
      nome: map['nome'],
      check: map['check'] ?? false,
    );
  }

  // bool get check => idVaga != null;
  static List<String> listaTipoBeneficio = [
    'Adicional de Embarque',
    'Adicional Noturno',
    'Alimentação No Local',
    'Comisão',
    'GymPass',
    'Plano De Saúde',
    'Plano Odontológico',
    'Participação Nos Lucros',
    'Seguro De Vida',
    'Vale Refeição',
    'Vale Transporte',
    'Vale Alimentação',
    'Outros',
  ];

  static List<Beneficio> listaBeneficio() {
    return listaTipoBeneficio
        .map((e) => Beneficio(idVaga: -1, nome: e))
        .toList();
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'idVaga': idVaga,
      'valor': valor,
      'observacao': observacao,
      'nome': nome,
      'check': check,
    };
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('check');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('check');
  }
}

// enum Beneficio {
//   adicionalDeEmbarque,
//   adicionalNoturno,
//   alimentacaoNoLocal,
//   comisao,
//   gymPass,
//   planoDeSaude,
//   planoOdontologico,
//   participacaoNosLucros,
//   seguroDeVida,
//   valeRefeicao,
//   valeTransporte,
//   valeAlimentacao,
//   outros,
// }

// extension BenefioExtension on Beneficio {
//   String get asString {
//     switch (this) {
//       case Beneficio.alimentacaoNoLocal:
//         return 'Alimentacão No Local';
//       case Beneficio.valeRefeicao:
//         return 'Vale Refeição';
//       case Beneficio.valeTransporte:
//         return 'Vale Transporte';
//       case Beneficio.valeAlimentacao:
//         return 'Vale Alimentação';
//       case Beneficio.planoDeSaude:
//         return 'Plano De Saúde';
//       case Beneficio.planoOdontologico:
//         return 'Plano Odontológico';
//       case Beneficio.participacaoNosLucros:
//         return 'Participação Nos Lucros';
//       case Beneficio.seguroDeVida:
//         return 'Seguro De Vida';
//       case Beneficio.adicionalNoturno:
//         return 'Adicional Noturno';
//       case Beneficio.adicionalDeEmbarque:
//         return 'Adicional De Embarque';
//       case Beneficio.comisao:
//         return 'Comisão';
//       case Beneficio.gymPass:
//         return 'Gym Pass';
//       case Beneficio.outros:
//         return 'Outros';
//       default:
//         throw Exception('Beneficio inválido');
//     }
//   }
// }

// Beneficio beneficioFromString(String tipo) {
//   switch (tipo) {
//     case 'Alimentacão No Local':
//       return Beneficio.alimentacaoNoLocal;
//     case 'Vale Refeição':
//       return Beneficio.valeRefeicao;
//     case 'Vale Transporte':
//       return Beneficio.valeTransporte;
//     case 'Vale Alimentação':
//       return Beneficio.valeAlimentacao;
//     case 'Plano De Saúde':
//       return Beneficio.planoDeSaude;
//     case 'Plano Odontológico':
//       return Beneficio.planoOdontologico;
//     case 'Participação Nos Lucros':
//       return Beneficio.participacaoNosLucros;
//     case 'Seguro De Vida':
//       return Beneficio.seguroDeVida;
//     case 'Adicional Noturno':
//       return Beneficio.adicionalNoturno;
//     case 'Adicional De Embarque':
//       return Beneficio.adicionalDeEmbarque;
//     case 'Comisão':
//       return Beneficio.comisao;
//     case 'Gym Pass':
//       return Beneficio.gymPass;
//     case 'Outros':
//       return Beneficio.outros;
//     default:
//       throw Exception('Beneficio inválido');
//   }
// }
