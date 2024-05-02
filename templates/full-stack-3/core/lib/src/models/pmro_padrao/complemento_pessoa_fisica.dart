import 'package:sibem_core/core.dart';

class ComplementoPessoaFisica implements SerializeBase {
  static const String schemaName = 'pmro_padrao';
  static const String tableName = 'complementos_pessoas_fisicas';

  /// fully qualified table name
  static const String fqtn = '$schemaName.$tableName';

  int idPessoa;
  int? idEscolaridade;
  String? nrCarteiraProfissional;
  String? nrSerieCarteiraProfissional;
  String? nrTituloEleitor;
  int? zonaTituloEleitor;
  int? secaoTituloEleitor;
  String? nrCertificadoReservista;
  bool? deficiente;
  int? idTipoDeficiencia;
  String? cid;
  String? descricaoDeficiencia;
  int? nrDependentes;
  String? categoriaHabilitacao;

  /// propriedade anexada
  String? nomeEscolaridade;

  ComplementoPessoaFisica({
    required this.idPessoa,
    this.idEscolaridade,
    this.nrCarteiraProfissional,
    this.nrSerieCarteiraProfissional,
    this.nrTituloEleitor,
    this.zonaTituloEleitor,
    this.secaoTituloEleitor,
    this.nrCertificadoReservista,
    this.deficiente,
    this.idTipoDeficiencia,
    this.cid,
    this.descricaoDeficiencia,
    this.nrDependentes,
    this.categoriaHabilitacao,
    //
    this.nomeEscolaridade,
  });

  factory ComplementoPessoaFisica.fromMap(Map<String, dynamic> map) {
    final comp = ComplementoPessoaFisica(
        idPessoa: map['idPessoa'],
        idEscolaridade: map['idEscolaridade'],
        nrCarteiraProfissional: map['nrCarteiraProfissional'],
        nrSerieCarteiraProfissional: map['nrSerieCarteiraProfissional'],
        nrTituloEleitor: map['nrTituloEleitor'],
        zonaTituloEleitor: map['zonaTituloEleitor'],
        secaoTituloEleitor: map['secaoTituloEleitor'],
        nrCertificadoReservista: map['nrCertificadoReservista'],
        deficiente: map['deficiente'],
        idTipoDeficiencia: map['idTipoDeficiencia'],
        cid: map['cid'],
        descricaoDeficiencia: map['descricaoDeficiencia'],
        nrDependentes: map['nrDependentes'],
        categoriaHabilitacao: map['categoriaHabilitacao']);

    if (map.containsKey('nomeEscolaridade')) {
      comp.nomeEscolaridade = map['nomeEscolaridade'];
    }
    return comp;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idPessoa': idPessoa,
      'idEscolaridade': idEscolaridade,
      'nrCarteiraProfissional': nrCarteiraProfissional,
      'nrSerieCarteiraProfissional': nrSerieCarteiraProfissional,
      'nrTituloEleitor': nrTituloEleitor,
      'zonaTituloEleitor': zonaTituloEleitor,
      'secaoTituloEleitor': secaoTituloEleitor,
      'nrCertificadoReservista': nrCertificadoReservista,
      'deficiente': deficiente,
      'nrDependentes': nrDependentes,
      'categoriaHabilitacao': categoriaHabilitacao
    };

    if (idTipoDeficiencia != null) {
      map['idTipoDeficiencia'] = idTipoDeficiencia;
    }
    if (cid != null) {
      map['cid'] = cid;
    }
    if (descricaoDeficiencia != null) {
      map['descricaoDeficiencia'] = descricaoDeficiencia;
    }
    if (nomeEscolaridade != null) {
      map['nomeEscolaridade'] = nomeEscolaridade;
    }

    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return toMap()..remove('nomeEscolaridade');
  }

  Map<String, dynamic> toUpdateMap() {
    return toMap()
      ..remove('idPessoa')
      ..remove('nomeEscolaridade');
  }

  @override
  String toString() {
    return 'ComplementoPessoaFisica(${toMap()})';
  }
}
