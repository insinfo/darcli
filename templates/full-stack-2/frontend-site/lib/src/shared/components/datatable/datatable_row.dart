import 'datatable_col.dart';

class DatatableRow {
  dynamic instance;
  dynamic id;
  int index;
  List<DatatableCol> columns = [];
  bool selected = false;
  String? styleCss;

  DatatableRow({
    required this.columns,
    this.instance,
    this.id,
    this.index = -1,
    this.styleCss,
  });

  void addColumn(DatatableCol column) {
    //columns ??= [];
    columns.add(column);
  }
}
