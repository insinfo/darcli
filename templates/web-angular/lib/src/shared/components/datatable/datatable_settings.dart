import 'datatable_col.dart';

class DatatableSettings {
  /// define as colunas que vão aparecer na tabela
  List<DatatableCol> colsDefinitions = [];

  // List<DatatableCol> get colsDefinitions => _colsDefinitions;

  bool enableGrouping = false;

  /// exibir a coluna do número de ordem
  bool showOrderNumberColumn = false;

  /// definir índice inicial do numero de ordem
  int _ordemIndex = 1;

  /// definir índice inicial do numero de ordem
  void setOrdemStartIndex(int ordem) {
    _ordemIndex = ordem;
  }

  /// [colsDefinitions] define as colunas que vão aparecer na tabela
  /// [showOrderNumberColumn] exibe uma coluna com um numero que enumera as linhas dos dados exbidos no dataTable
  DatatableSettings(
      {required this.colsDefinitions,
      this.enableGrouping = false,
      this.showOrderNumberColumn = false}) {
    if (showOrderNumberColumn) {
      final col = DatatableCol(
          key: 'ordem',
          title: 'Ordem',visibility: false,
          customRenderString: (itemMap, itemInstance) {
            return '${_ordemIndex++}';
          });
      colsDefinitions.insert(0, col);
    }
  }

  // Iterable<int> countDownFromSyncRecursive(int num) sync* {
  //   if (num > 0) {
  //     yield num;
  //     yield* countDownFromSyncRecursive(num - 1);
  //   }
  // }

  // Iterable<int> genSerial(int num) sync* {
  //   if (num > 0) {
  //     yield num;
  //     yield* genSerial(num + 1);
  //   }
  // }

  // Iterable<int> generateNum() sync* {
  //   int n = 0;
  //   while (true) {
  //     yield n++;
  //   }
  // }
}
