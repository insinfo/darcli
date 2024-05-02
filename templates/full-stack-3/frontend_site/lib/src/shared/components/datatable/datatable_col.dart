import 'dart:html';

import 'datatable_style.dart';

enum DatatableColType { normal, groupTitle }

class DatatableCol {
  // value Key
  String key;
  String? sortingBy;
  dynamic id;
  String value;

  /// html Element to append do TD used internal with customRenderHtml
  Element? htmlElement;
  dynamic instance;
  String title;
  DatatableFormat? format;
  //DatatableStyle? style;
  String? styleCss;

  /// se vai esta visivel
  bool visibility = true;

  /// se vai estar visivel no modo grid
  bool visibilityOnCard = true;

  /// se exibe o titulo da coluna no card do modo grid
  bool showTitleOnCard = true;

  bool showAsFooterOnCard = false;

  bool enableSorting = false;

  /// customiza a renderização da String dentro da Celula
  String Function(Map<String, dynamic> itemMap, dynamic itemInstance)?
      customRenderString;

  Element Function(Map<String, dynamic> itemMap, dynamic itemInstance)?
      customRenderHtml;

  /// when more than one value has been displayed in the same column, use this field to define the separator
  String multiValSeparator = ' - ';

  bool enableGrouping = false;

  /// define o valor que sera usado para fazer o agrupamento
  String? groupByKey;

  /// colspan da td
  int? colspan;

  DatatableColType type = DatatableColType.normal;

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
    this.customRenderString,
    this.customRenderHtml,
    this.multiValSeparator = ' - ',
    this.sortingBy,
    this.htmlElement,
    this.enableGrouping = false,
    this.groupByKey,
    this.colspan,
    this.visibilityOnCard = true,
    this.showTitleOnCard = true,
    this.showAsFooterOnCard = false,
    this.type = DatatableColType.normal,
  });
}
