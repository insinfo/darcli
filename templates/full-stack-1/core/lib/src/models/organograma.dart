// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:new_sali_core/new_sali_core.dart';

/// esta classe representa um item da estrutura hieraquica Orgao/Unidade/Departamento/Setor etc
class Organograma implements SerializeBase {
  //int id = -1;
  //int? idPai;

  /// treeViewNodeLabel
  String label = '';
  bool active = false;

  /// treeViewNodes
  //List<Organograma> children = <Organograma>[];
  List<Organograma> _children = <Organograma>[];

  ///  Children
  List<Organograma> get children {
    return _children;
  }

  set children(List<Organograma> orgs) {
    _children = <Organograma>[];
    addChilds(orgs);
  }

  void addChild(Organograma child) {
    child.parent = this;
    _children.add(child);
  }

  void addChilds(List<Organograma> orgs) {
    for (final org in orgs) {
      addChild(org);
    }
  }

  /// treeViewNodeLevel
  int level = 0;

  ///  treeViewNodeFilter
  bool filter = true;

  Organograma? parent;

  /// treeViewNodeIsCollapse
  bool isCollapse = true;

  /// treeViewNodeIsSelected
  bool isSelected = false;

  bool isDisabled = false;

  int? codOrgao;
  int? codUnidade;
  int? codDepartamento;
  int? codSetor;
  String? anoExercicio;

  ///  usuarioResponsavel setor pode ser 0
  int? usuarioResponsavelSetor;

  int? idSetor;

  /// para sebar se é Orgao/Unidade/De...
  String type;

  //isto é para o ngTemplateOutlet <ng-container *ngTemplateOutlet="recursiveList; context: item.templateOutletContext ">
  late Map<String, dynamic> templateOutletContext;

  /// propriedade anexada nome Orgao
  String? nomOrgao;

  /// propriedade anexada nome Unidade
  String? nomUnidade;

  /// propriedade anexada nome Departamento
  String? nomDepartamento;

  /// propriedade anexada nome Setor
  String? nomSetor;

  Organograma({
    required this.label,
    this.active = false,
    this.level = 0,
    this.codOrgao,
    this.codUnidade,
    this.codDepartamento,
    this.codSetor,
    this.idSetor,
    this.anoExercicio,
    this.usuarioResponsavelSetor,
    required this.type,
    this.isDisabled = false,
    this.nomOrgao,
    this.nomUnidade,
    this.nomDepartamento,
    this.nomSetor,
    required List<Organograma> children,
  }) {
    templateOutletContext = {'\$implicit': children};
    _children = <Organograma>[];
    addChilds(children);
  }

  bool get isSetor {
    return codSetor != null &&
        codOrgao != null &&
        codUnidade != null &&
        codDepartamento != null &&
        codSetor != null &&
        idSetor != null &&
        anoExercicio != null;
  }

  Setor? asSetor() {
    if (isSetor) {
      final setor = Setor(
        nomSetor: label,
        codOrgao: codOrgao!,
        codUnidade: codUnidade!,
        codDepartamento: codDepartamento!,
        id: idSetor!,
        codSetor: codSetor!,
        anoExercicio: anoExercicio!,
        usuarioResponsavel: usuarioResponsavelSetor ?? 0,
      );

      setor.nomOrgao = nomOrgao;
      setor.nomUnidade = nomUnidade;
      setor.nomDepartamento = nomDepartamento;
      return setor;
    }

    return null;
  }

  /// verifica se tem filhos
  bool hasChilds() {
    return this.children.isNotEmpty == true;
  }

  bool hasChilds2(Organograma item) {
    return item.children.isNotEmpty == true;
  }

  bool finded(String searchQuery, Organograma item, {bool searchById = false}) {
    if (searchById) {
      return item.idSetor.toString() == searchQuery;
    } else {
      final itemTitle = SaliCoreUtils.removerAcentos(item.label).toLowerCase();
      return itemTitle.contains(searchQuery);
    }
  }

  /// se todos os filhos estão selecionados
  bool get isAllChildrenSelected {
    var filhos = getAllDescendants().toList();
    // var isSelected = filhos.where((el) => el.treeViewNodeIsSelected).toList();
    // return filhos.length == isSelected.length;
    for (var filho in filhos) {
      if (filho.isSelected == false) {
        return false;
      }
    }
    return true;
  }

  List<Organograma> getParents() {
    var resuts = <Organograma>[];
    var parent = this.parent;
    while (parent != null) {
      resuts.add(parent);
      parent = parent.parent;
    }
    return resuts;
  }

  /// retorna o primeiro filho que corresponde ao childSelector
  Organograma? getChild(bool Function(Organograma) childSelector) {
    final allNodes = getAllDescendants();
    final parentsOfSelectedChildren =
        allNodes.where((node) => node.children.any(childSelector));
    return parentsOfSelectedChildren.isNotEmpty
        ? parentsOfSelectedChildren.first
        : null;
  }

  /// retorna todos os nodes filhos ou seja transforma a arvore em uma lista
  Iterable<Organograma> getAllDescendants(
      [Iterable<Organograma>? rootNodesP]) sync* {
    var rootNode = this;
    var rootNodes = rootNodesP ?? [rootNode];
    final descendants =
        rootNodes.expand((node) => getAllDescendants(node.children));
    yield* rootNodes.followedBy(descendants);
  }

  Organograma clone() {
    return Organograma.fromJson(toJson());
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map.addAll({
      'codOrgao': codOrgao,
      'codUnidade': codUnidade,
      'codDepartamento': codDepartamento,
      'codSetor': codSetor,
      'idSetor': idSetor,
      'anoExercicio': anoExercicio,
      'level': level,
      'label': label,
      'active': active,
      'type': type,
      'isDisabled': isDisabled,
      'usuarioResponsavelSetor': usuarioResponsavelSetor,
      'nomOrgao': nomOrgao,
      'nomUnidade': nomUnidade,
      'nomDepartamento': nomDepartamento,
      'nomSetor': nomSetor,
    });
    map['children'] = children.map((x) => x.toMap()).toList();
    return map;
  }

  factory Organograma.fromMap(Map<String, dynamic> map) {
    final org = Organograma(
      label: map['label'],
      type: map['type'],
      active: map['active'],
      level: map['level'],
      codOrgao: map['codOrgao'],
      codUnidade: map['codUnidade'],
      codDepartamento: map['codDepartamento'],
      codSetor: map['codSetor'],
      anoExercicio: map['anoExercicio'],
      isDisabled: map['isDisabled'],
      idSetor: map['idSetor'],
      usuarioResponsavelSetor: map['usuarioResponsavelSetor'],
      nomOrgao: map['nomOrgao'],
      nomUnidade: map['nomUnidade'],
      nomDepartamento: map['nomDepartamento'],
      nomSetor: map['nomSetor'],
      children: List<Organograma>.from(
        (map['children'] as List).map<Organograma>(
          (x) => Organograma.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );

    return org;
  }

  String toJson() => json.encode(toMap());

  factory Organograma.fromJson(String source) =>
      Organograma.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Organograma( label: $label,   active: $active, children: $children, level: $level, codOrgao: $codOrgao, codUnidade: $codUnidade, codDepartamento: $codDepartamento, codSetor: $codSetor, anoExercicio: $anoExercicio)';
  }

  @override
  bool operator ==(covariant Organograma other) {
    if (identical(this, other)) return true;

    return other.codOrgao == codOrgao &&
        other.codUnidade == codUnidade &&
        other.codDepartamento == codDepartamento &&
        other.codSetor == codSetor &&
        other.anoExercicio == anoExercicio;
  }

  @override
  int get hashCode {
    return codOrgao.hashCode ^
        codUnidade.hashCode ^
        codDepartamento.hashCode ^
        codSetor.hashCode ^
        anoExercicio.hashCode;
  }
}
