import 'dart:collection';
import 'dart:convert';

import 'package:esic_core/src/core_utils.dart';

import 'serialize_base.dart';

const emptyList = <Type>[];

class DataFrame<T> extends ListBase<T> {
  List<T> items = [];
  int totalRecords = 0;
  dynamic error = '';

  DataFrame(
      {required this.items, required this.totalRecords, this.error = ''}) {
    //isto é para o ngTemplateOutlet <ng-container *ngTemplateOutlet="recursiveList; context: item.contextForRender ">
    templateOutletContext = {'\$implicit': this};
  }

  List<Map<String, dynamic>> get itemsAsMap {
    if (items.isEmpty == true) {
      return [];
    }
    if (items.first is LinkedHashMap<String, dynamic>) {
      return items as List<Map<String, dynamic>>;
    }
    try {
      // ignore: unused_local_variable
      var r = items.first as SerializeBase;
    } catch (e) {
      error =
          'o Tipo ${T.toString()} em uso pela DataFrame class não herda da SerializeBase class e tambem não é um Map!';
    }

    return items.map((e) => (e as SerializeBase).toMap()).toList();
  }

  /// remove one element of DataFrame and return index of this element
  int removeItem(T element) {
    var idx = items.indexOf(element);
    items.remove(element);
    return idx;
  }

  DataFrame.fromMap(
      Map<String, dynamic> map, T Function(Map<String, dynamic>) factoryes) {
    if (map.containsKey('items') && map['items'] is List) {
      var maps = map['items'] as List;

      items = <T>[];
      for (var map in maps) {
        var model = factoryes(map);
        items.add(model);
      }
    }

    totalRecords = map['totalRecords'];
    error = map['error'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': itemsAsMap,
      'totalRecords': totalRecords,
      'error': error,
    };
  }

  @override
  String toString() {
    return 'instanceof DataFrame | ${jsonEncode(toMap())} ';
  }

  String toJson() {
    var map = toMap();
    var json = jsonEncode(map, toEncodable: CoreUtils.customJsonEncode);

    return json;
  }

  @override
  set length(int newLength) {
    items.length = newLength;
  }

  @override
  int get length => items.length;

  @override
  T operator [](int index) => items[index];

  @override
  void operator []=(int index, T value) {
    items[index] = value;
  }

  ///isto é para o ngTemplateOutlet <ng-container *ngTemplateOutlet="recursiveList; context: item.contextForRender ">
  late Map<String, dynamic> templateOutletContext;
}
