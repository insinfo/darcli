import 'package:new_sali_core/src/models/base_model.dart';

class Modulo implements BaseModel {
  static const String schemaName = 'administracao';
  static const String tableName = 'modulo';

  /// nome da tabela totalmente qualificado
  static const String fqtn = '$schemaName.$tableName';

  int codModulo;
  int? codResponsavel;
  String nomModulo;
  String? nomDiretorio;
  int ordem;
  int? codGestao;

  /// propriedades anexadas
  String? nomAcao;
  String? nomFuncionalidade;
  int? numCgm;
  bool? temPermissao;
  int? codAcao;
  int? codFuncionalidade;

  Modulo({
    required this.codModulo,
    this.codResponsavel,
    required this.nomModulo,
    this.nomDiretorio,
    required this.ordem,
    this.codGestao,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'cod_modulo': codModulo,
      'cod_responsavel': codResponsavel,
      'nom_modulo': nomModulo,
      'nom_diretorio': nomDiretorio,
      'ordem': ordem,
      'cod_gestao': codGestao,
    };
    if (nomAcao != null) {
      map['nom_acao'] = nomAcao;
    }
    if (nomFuncionalidade != null) {
      map['nom_funcionalidade'] = nomFuncionalidade;
    }
    if (numCgm != null) {
      map['numcgm'] = numCgm;
    }
    if (temPermissao != null) {
      map['tem_permissao'] = temPermissao;
    }
    if (codAcao != null) {
      map['cod_acao'] = codAcao;
    }
    if (codFuncionalidade != null) {
      map['cod_funcionalidade'] = codFuncionalidade;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('nom_acao')
      ..remove('nom_funcionalidade')
      ..remove('numcgm')
      ..remove('tem_permissao')
      ..remove('cod_acao')
      ..remove('cod_funcionalidade');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('cod_modulo')
      ..remove('nom_acao')
      ..remove('nom_funcionalidade')
      ..remove('numcgm')
      ..remove('tem_permissao')
      ..remove('cod_acao')
      ..remove('cod_funcionalidade');
  }

  factory Modulo.fromMap(Map<String, dynamic> map) {
    var m = Modulo(
      codModulo: map['cod_modulo'] as int,
      codResponsavel: map['cod_responsavel'],
      nomModulo: map['nom_modulo'] as String,
      nomDiretorio: map['nom_diretorio'],
      ordem: map['ordem'] as int,
      codGestao: map['cod_gestao'],
    );

    if (map.containsKey('nom_acao')) {
      m.nomAcao = map['nom_acao'];
    }
    if (map.containsKey('nom_funcionalidade')) {
      m.nomFuncionalidade = map['nom_funcionalidade'];
    }
    if (map.containsKey('numcgm')) {
      m.numCgm = map['numcgm'];
    }
    if (map.containsKey('tem_permissao')) {
      m.temPermissao = map['tem_permissao'];
    }
    if (map.containsKey('cod_acao')) {
      m.codAcao = map['cod_acao'];
    }
    if (map.containsKey('cod_funcionalidade')) {
      m.codFuncionalidade = map['cod_funcionalidade'];
    }
    return m;
  }

  @override
  String toString() {
    return 'Modulo(cod_modulo: $codModulo, cod_responsavel: $codResponsavel, nom_modulo: $nomModulo, nom_diretorio: $nomDiretorio, ordem: $ordem, cod_gestao: $codGestao)';
  }

  @override
  bool operator ==(covariant Modulo other) {
    if (identical(this, other)) return true;

    return other.codModulo == codModulo;
  }

  @override
  int get hashCode {
    return codModulo.hashCode;
  }
}
