import 'dart:collection';
import 'dart:convert';

import 'package:esic_core/src/models/filter.dart';

class FilterSearchField {
  String label;

  /// campo da tabela
  String field;
  bool active;
  String operator;

  FilterSearchField(
      {required this.label,
      required this.field,
      this.active = false,
      this.operator = '='});

  factory FilterSearchField.fromMap(Map<String, dynamic> map) {
    return FilterSearchField(
      label: map['label'],
      field: map['field'],
      active: map['active'],
      operator: map['operator'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'field': field,
      'active': active,
      'operator': operator,
    };
  }
}

class Filters {
  int? limit = 12;
  int? offset = 0;

  String? searchString;
  List<FilterSearchField> searchInFields = [];

  String? orderBy;
  String? orderDir = 'desc';
  Map<String, String> additionalParams = {};
  List<Filter> additionalFilters = [];

  void addSearchInField(FilterSearchField filterSearchField) {
    searchInFields.add(filterSearchField);
  }

  Filters(
      {this.limit = 12,
      this.offset = 0,
      this.searchString,
      this.orderBy,
      this.orderDir = 'desc'});

  bool get isOrder => orderBy != null;
  bool get isSearch => searchString != null && searchString?.trim() != '';

  bool get isLimit => limit != null;
  bool get isOffset => offset != null;

  Filters.fromMap(Map<String, dynamic> map) {
    fillFromMap(map);
  }

  final _defaultParams = [
    'limit',
    'offset',
    'search',
    'orderBy',
    'orderDir',
    'additionalFilters'
  ];

  void fillFromFilters(Filters filters) {
    limit = filters.limit;
    offset = filters.offset;
    searchString = filters.searchString;
    orderBy = filters.orderBy;
    orderDir = filters.orderDir;
    searchInFields = filters.searchInFields;
    additionalParams = filters.additionalParams;
    additionalFilters = filters.additionalFilters;
  }

  String? getAdditionalParamByName(String name) {
    for (var pa in additionalParams.entries) {
      if (pa.key == name) {
        return pa.value;
      }
    }
    return null;
  }

  void fillFromMap(Map<String, dynamic> map) {
    if (map.containsKey('limit') && map['limit'] != null) {
      limit = int.tryParse(map['limit'].toString());
    }
    if (map.containsKey('offset') && map['offset'] != null) {
      offset = int.tryParse(map['offset'].toString());
    }
    if (map.containsKey('search') && map['search'] != null) {
      searchString = map['search'];
    }
    if (map.containsKey('orderBy') && map['orderBy'] != null) {
      orderBy = map['orderBy'];
    }
    if (map.containsKey('orderDir') && map['orderDir'] != null) {
      orderDir = map['orderDir'];
    }

    if (map.containsKey('searchInFields')) {
      if (map['searchInFields'] is String) {
        var json = jsonDecode(map['searchInFields']) as List;
        searchInFields = json.map((e) => FilterSearchField.fromMap(e)).toList();
      } else if (map['searchInFields'] is List<FilterSearchField>) {
        searchInFields = map['searchInFields'];
      } else if (map['searchInFields']
          is List<LinkedHashMap<String, dynamic>>) {
        searchInFields = map['searchInFields']
            .map((e) => FilterSearchField.fromMap(e))
            .toList();
      } else if (map['searchInFields'] is List<Map<String, dynamic>>) {
        searchInFields = map['searchInFields']
            .map((e) => FilterSearchField.fromMap(e))
            .toList();
      }
    }

    map.forEach((key, value) {
      if (!_defaultParams.contains(key)) {
        additionalParams.addAll({key: value});
      }
    });

    if (map.containsKey('additionalFilters')) {
      if (map['additionalFilters'] is String) {
        var json = jsonDecode(map['additionalFilters']) as List;
        additionalFilters = json.map((e) => Filter.fromMap(e)).toList();
      } else if (map['additionalFilters'] is List<Filter>) {
        additionalFilters = map['additionalFilters'];
      } else if (map['additionalFilters']
          is List<LinkedHashMap<String, dynamic>>) {
        additionalFilters =
            map['additionalFilters'].map((e) => Filter.fromMap(e)).toList();
      } else if (map['additionalFilters'] is List<Map<String, dynamic>>) {
        additionalFilters =
            map['additionalFilters'].map((e) => Filter.fromMap(e)).toList();
      }
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    // if (limit != null) {
    map['limit'] = limit;
    // }
    // if (offset != null) {
    map['offset'] = offset;
    // }
    //if (searchString != null) {
    map['search'] = searchString;
    //}
    //if (orderBy!= null) {
    map['orderBy'] = orderBy;
    // }
    //if (orderDir != null) {
    map['orderDir'] = orderDir;
    //}

    if (searchInFields.isNotEmpty) {
      map['searchInFields'] = searchInFields.map((e) => e.toMap()).toList();
    }
    if (additionalFilters.isNotEmpty) {
      map['additionalFilters'] =
          additionalFilters.map((e) => e.toMap()).toList();
    }
    return map;
  }

  void reset({
    bool clearAdditionalParams = true,
    bool clearAdditionalFilters = true,
    bool clearSearchInFields = false,
  }) {
    limit = 12;
    offset = 0;
    searchString = null;
    orderBy = null;
    orderDir = 'desc';
    if (clearAdditionalParams) {
      additionalParams = {};
    }
    if (clearAdditionalFilters) {
      additionalFilters = [];
    }
    if (clearSearchInFields) {
      searchInFields = [];
    }
  }

  Map<String, String?> getParams() {
    var stringParams = <String, String?>{};
    if (additionalParams.isNotEmpty == true) {
      stringParams.addAll(additionalParams);
    }
    if (limit != null) {
      stringParams['limit'] = limit.toString();
    }
    if (offset != null) {
      stringParams['offset'] = offset.toString();
    }
    if (searchString != null) {
      stringParams['search'] = searchString;
    }
    if (orderBy != null) {
      stringParams['orderBy'] = orderBy;
    }
    if (orderDir != null) {
      stringParams['orderDir'] = orderDir;
    }
    if (additionalFilters.isNotEmpty == true) {
      stringParams['additionalFilters'] =
          jsonEncode(additionalFilters.map((e) => e.toMap()).toList());
    }

    if (searchInFields.isNotEmpty == true) {
      stringParams['searchInFields'] =
          jsonEncode(searchInFields.map((e) => e.toMap()).toList());
    }
    return stringParams;
  }

  /* void addParam(String paramName, String paramValue) {
    if (paramName != null && paramName.isNotEmpty) {
      stringParams[paramName] = paramValue;
    }
  }

  void addParams(Map<String, String> params) {
    stringParams.addAll(params);
  }*/
}
