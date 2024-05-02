import 'datatable_style.dart';

class DatatableCol {
  // value Key
  String key;
  String? sortingBy;
  dynamic id;
  String value;
  dynamic instance;
  String title;
  DatatableFormat? format;
  //DatatableStyle? style;
  String? styleCss;
  bool visibility = true;
  bool enableSorting = false;
  String Function(Map<String, dynamic> itemMap, dynamic itemInstance)?
      customRender;

  /// when more than one value has been displayed in the same column, use this field to define the separator
  String multiValSeparator = ' - ';

  DatatableCol({
    this.id,
    required this.key,
    this.value = '',
    this.instance,
    required this.title,
    this.format,
    this.styleCss,
    this.visibility = true,
    this.enableSorting = false,
    this.customRender,
    this.multiValSeparator = ' - ',
    this.sortingBy,
  });
}
