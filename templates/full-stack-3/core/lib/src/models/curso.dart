import 'package:sibem_core/core.dart';

class Curso implements SerializeBase {
  static const String schemaName = 'banco_empregos';
  static const String tableName = 'cursos';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  static const String nameCol = 'nome';

  static const String idFqCol = '$tableName.$idCol';
  static const String idCol = 'id';

  static const String tipoCursoCol = 'tipoCurso';

  int id; //! Obrigatorio
  String nome; //! Obrigatorio
  String tipoCurso; //! Obrigatorio

  ///Referente a candidato curso
  DateTime? dataConclusao;

  ///Referente a vaga curso
  bool? obrigatorio;

  bool isSelected = false;

  /// Vaga Curso
  int? idVaga;
  int? idCandidato;

  Map<String, dynamic> toInsertVagaCurso() {
    return {
      'idVaga': idVaga,
      'idCurso': id,
      'obrigatorio': obrigatorio,
    };
  }

  /// candidatos_cursos
  Map<String, dynamic> toInsertCandidatoCurso() {
    print('toInsertCandidatoCurso idCurso $id');
    return {
      'idCandidato': idCandidato,
      'idCurso': id,
      'dataConclusao': dataConclusao,
    };
  }

  Curso(
      {this.id = -1,
      required this.nome,
      required this.tipoCurso,
      this.isSelected = false});

  factory Curso.fromMap(Map<String, dynamic> map) {
    final cu = Curso(
      id: map['id'],
      nome: map['nome'],
      tipoCurso: map['tipoCurso'],
    );

    if (map['obrigatorio'] != null) {
      cu.obrigatorio = map['obrigatorio'];
    }

    if (map['dataConclusao'] is DateTime) {
      cu.dataConclusao = map['dataConclusao'];
    } else if (map['dataConclusao'] is String) {
      cu.dataConclusao = DateTime.parse(map['dataConclusao']);
    }

    return cu;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'nome': nome,
      'tipoCurso': tipoCurso,
    };

    if (dataConclusao != null) {
      map['dataConclusao'] = dataConclusao!.toIso8601String();
    }
    if (obrigatorio != null) {
      map['obrigatorio'] = obrigatorio;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()
      ..remove('id')
      ..remove('tipoCursoNome')
      ..remove('dataConclusao')
      ..remove('obrigatorio');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('id')
      ..remove('tipoCursoNome')
      ..remove('dataConclusao')
      ..remove('obrigatorio');
  }
}
