

class Filter {
  String key;
  String? value;
  String operator;

  Filter({required this.key, this.operator = '=', this.value});

  factory Filter.fromMap(Map<String, dynamic> map) {
    return Filter(
      key: map['key'],
      value: map['value'],
      operator: map['operator'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['key'] = key;
    map['value'] = value;
    map['operator'] = operator;
    return map;
  }
}
