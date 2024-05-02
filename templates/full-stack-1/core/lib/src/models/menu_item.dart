// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:new_sali_core/new_sali_core.dart';

class MenuItem implements SerializeBase {
  //int id = -1;
  //int? idPai;
  String? rota;
  String label = '';
  String? icone;
  String? cor;
  int ordem = 0;
  bool active = false;
  List<MenuItem> children = <MenuItem>[];
  int level = 0;
  bool filter = true;
  MenuItem? parent;
  bool isCollapse = true;

  int? codGestao;
  int? codModulo;
  int? codFuncionalidade;
  int? codAcao;

  //isto é para o ngTemplateOutlet <ng-container *ngTemplateOutlet="recursiveList; context: item.templateOutletContext ">
  late Map<String, dynamic> templateOutletContext;

  String? type;

  MenuItem({
    this.rota,
    required this.label,
    this.icone,
    this.cor,
    this.ordem = 0,
    this.active = false,
    required this.children,
    this.level = 0,
    this.type,
    this.codGestao,
    this.codModulo,
    this.codFuncionalidade,
    this.codAcao,
  }) {
    templateOutletContext = {'\$implicit': children};
  }

  bool hasChilds(MenuItem item) {
    return item.children.isNotEmpty == true;
  }

  bool finded(String _search_query, MenuItem item) {
    var item_title = SaliCoreUtils.removerAcentos(item.label).toLowerCase();
    return item_title.contains(_search_query);
  }

  MenuItem clone() {
    return MenuItem.fromJson(toJson());
  }

  MenuItem copyWith({
    String? rota,
    String? label,
    String? icone,
    String? cor,
    int? ordem,
    bool? active,
    List<MenuItem>? children,
    int? level,
    bool? filter,
    bool? isCollapse,
    int? codGestao,
    int? codModulo,
    int? codFuncionalidade,
    int? codAcao,
  }) {
    return MenuItem(
      rota: rota,
      label: label ?? this.label,
      icone: icone ?? this.icone,
      cor: cor ?? this.cor,
      ordem: ordem ?? this.ordem,
      active: active ?? this.active,
      children: children ?? this.children,
      level: level ?? this.level,
      codGestao: codGestao ?? this.codGestao,
      codModulo: codModulo ?? this.codModulo,
      codFuncionalidade: codFuncionalidade ?? this.codFuncionalidade,
      codAcao: codAcao ?? this.codAcao,
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (type != null) {
      map['type'] = type;
    }
    map.addAll({
      'codGestao': codGestao,
      'codModulo': codModulo,
      'codFuncionalidade': codFuncionalidade,
      'codAcao': codAcao,
      'level': level,
      'rota': rota,
      'label': label,
      //   'icone': icone,
      //   'cor': cor,
      'ordem': ordem,
      'active': active,
    });
    map['children'] = children.map((x) => x.toMap()).toList();
    return map;
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      rota: map['rota'],
      label: map['label'] as String,
      icone: map['icone'] != null ? map['icone'] as String : null,
      cor: map['cor'] != null ? map['cor'] as String : null,
      ordem: map['ordem'] as int,
      active: map['active'] ,
      children: List<MenuItem>.from(
        (map['children'] as List).map<MenuItem>(
          (x) => MenuItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      level: map['level'] as int,
      type: map['type'],
      codGestao: map['codGestao'],
      codModulo: map['codModulo'],
      codFuncionalidade: map['codFuncionalidade'],
      codAcao: map['codAcao'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MenuItem.fromJson(String source) =>
      MenuItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MenuItem(rota: $rota, label: $label, icone: $icone, cor: $cor, ordem: $ordem, active: $active, children: $children, level: $level, codGestao: $codGestao, codModulo: $codModulo, codFuncionalidade: $codFuncionalidade, codAcao: $codAcao)';
  }

  @override
  bool operator ==(covariant MenuItem other) {
    if (identical(this, other)) return true;
    //final listEquals = const DeepCollectionEquality().equals;
    return other.label == label;
  }

  @override
  int get hashCode {
    return label.hashCode;
  }
}
