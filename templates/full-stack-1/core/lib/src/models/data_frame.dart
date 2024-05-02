import 'dart:collection';
import 'dart:convert';
import 'package:new_sali_core/src/utils/core_utils.dart';
import 'serialize_base.dart';

const emptyList = <Type>[];

//T extends SerializeBase
class DataFrame<T> extends ListBase<T> {
  List<T> items = [];
  int totalRecords = 0;
  dynamic error = '';

  DataFrame(
      {required this.items, required this.totalRecords, this.error = ''}) {
    //isto é para o ngTemplateOutlet <ng-container *ngTemplateOutlet="recursiveList; context: item.contextForRender ">
    templateOutletContext = {'\$implicit': this};
  }

  // factory DataFrame.fromList(List<T> items){
  //   return DataFrame(items: items,totalRecords: items.length);
  // }

  factory DataFrame.newClear() => DataFrame<T>(items: [], totalRecords: 0);

  // external factory List.from(Iterable elements, {bool growable = true});

  List<Map<String, dynamic>> get itemsAsMap {
    if (items.isEmpty == true) {
      return [];
    }
    if (items.first is LinkedHashMap<String, dynamic> ||
        items.first is Map<String, dynamic>) {
      return items as List<Map<String, dynamic>>;
    }
    try {
      // ignore: unused_local_variable
      var r = items.first as SerializeBase;
    } catch (e) {
      error =
          'o Tipo ${T.toString()} em uso pela DataFrame class não herda da SerializeBase class e também não é um Map!';
    }

    return items.map((e) => (e as SerializeBase).toMap()).toList();
  }

  /// remove one element of DataFrame and return index of this element
  int removeItem(T element) {
    var idx = items.indexOf(element);
    items.remove(element);
    return idx;
  }

  factory DataFrame.fromMapWithFactory(Map<String, dynamic> map,
      [T Function(Map<String, dynamic>)? builder]) {
    final dados = <T>[];

    if (T is SerializeBase && builder == null) {
      throw Exception('se T for SerializeBase, builder não pode ser nulo');
    }

    if (map.containsKey('items') && map['items'] is List) {
      var maps = map['items'] as List;

      for (var map in maps) {
        var obj = builder != null ? builder(map) : map;
        dados.add(obj);
      }
    }

    final totalRecords = map['totalRecords'];
    final error = map['error'];

    return DataFrame<T>(items: dados, totalRecords: totalRecords, error: error);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalRecords': totalRecords,
      'error': error,
      'items': itemsAsMap,
    };
  }

  ///
  List<D> toListOf<D>(D Function(Map<String, dynamic>) factories) {
    if (items.isEmpty == true) {
      return [];
    }

    if (items.first is D) {
      return items as List<D>;
    } else if (items.first is Map<String, dynamic>) {
      return items.map((e) => factories(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  String toString() {
    return 'instanceof DataFrame | ${jsonEncode(toMap())} ';
  }

  String toJson() {
    final map = toMap();
    final json = jsonEncode(map, toEncodable: SaliCoreUtils.customJsonEncode);
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
