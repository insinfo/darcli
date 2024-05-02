import 'package:sibem_core/core.dart';

class ConhecimentoExtra implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'conhecimentos_extras';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';
  
  static const String idFqCol = '$tableName.$idCol';
  static const String idCol = 'id';

  /// Obrigatorio
  int id;

  /// Obrigatorio
  int idTipoConhecimento;

  /// Obrigatorio
  String nome;

  /// propriedades anexadas Obrigatorio
  String? nivelConhecimento;
  TipoConhecimento? _tipoConhecimento;

  /// Campo da tabela TipoConhecimento
  String? tipoConhecimentoNome;

  /// Obrigatorio
  bool? obrigatorio;
  bool isSelected = false;

  /// Vaga Conhecimento Extra
  int? idVaga;

  /// candidatos_conhecimentos_extras
  int? idCandidato;

  Map<String, dynamic> toInsertVagaConhecimentoExtra() {
    return {
      'idVaga': idVaga,
      'idConhecimentoExtra': id,
      'obrigatorio': obrigatorio,
    };
  }

  /// para cadastrar na tabela candidatos_conhecimentos_extras
  Map<String, dynamic> toInsertCandidatoConhecimentoExtra() {
    return {
      'idCandidato': idCandidato,
      'idConhecimentoExtra': id,
      'nivelConhecimento': nivelConhecimento,
    };
  }

  ConhecimentoExtra({
    this.id = -1,
    required this.nome,
    required this.idTipoConhecimento,
    //propriedade anexadas
    this.tipoConhecimentoNome,
    this.obrigatorio,
    this.isSelected = false,
  });

  factory ConhecimentoExtra.fromMap(Map<String, dynamic> map) {
    final co = ConhecimentoExtra(
      id: map['id'],
      nome: map['nome'],
      idTipoConhecimento: map['idTipoConhecimento'],
    );
    if (map['tipoConhecimentoNome'] != null) {
      co.tipoConhecimentoNome = map['tipoConhecimentoNome'];
    }
    if (map['nivelConhecimento'] != null) {
      co.nivelConhecimento = map['nivelConhecimento'];
    }
    if (map['obrigatorio'] != null) {
      co.obrigatorio = map['obrigatorio'];
    }
    return co;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'nome': nome,
      'idTipoConhecimento': idTipoConhecimento,
    };

    if (tipoConhecimento != null) {
      map['tipoConhecimento'] = tipoConhecimento!.toMap();
    }

    if (tipoConhecimentoNome != null) {
      map['tipoConhecimentoNome'] = tipoConhecimentoNome;
    }

    if (nivelConhecimento != null) {
      map['nivelConhecimento'] = nivelConhecimento;
    }

    if (obrigatorio != null) {
      map['obrigatorio'] = obrigatorio;
    }
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('tipoConhecimento')
      ..remove('tipoConhecimentoNome')
      ..remove('nivelConhecimento')
      ..remove('obrigatorio');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('tipoConhecimento')
      ..remove('tipoConhecimentoNome')
      ..remove('nivelConhecimento')
      ..remove('obrigatorio');
  }

  TipoConhecimento? get tipoConhecimento {
    return _tipoConhecimento;
  }
}
