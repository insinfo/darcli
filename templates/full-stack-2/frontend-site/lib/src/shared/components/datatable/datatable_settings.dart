import 'datatable_col.dart';

class DatatableSettings {
  String? keyOfId;
  List<DatatableCol> colsDefinitions = [];
  DatatableSettings({this.keyOfId, required this.colsDefinitions});

  /*List<String> get visibleTitles => rowDefinitions?.isNotEmpty == true
      ? rowDefinitions
          .where((e) => e.visibility == true)
          .map((e) => e.title)
          .toList()
      : [];

  List<String> get allTitles => rowDefinitions?.isNotEmpty == true
      ? rowDefinitions.map((e) => e.title).toList()
      : [];

  List<String> get allKeys => rowDefinitions?.isNotEmpty == true
      ? rowDefinitions.map((e) => e.valueKey).toList()
      : [];*/
}
