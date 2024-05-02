import 'dart:async';

import 'package:esic_core/esic_core.dart';

import '../../components/loading/loading.dart';

import '../../directives/dropdown_menu_directive.dart';
import '../../directives/safe_inner_html_directive.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import 'dart:html';

import 'datatable_col.dart';
import 'datatable_row.dart';
import 'datatable_settings.dart';
import 'datatable_style.dart';

import 'package:intl/intl.dart';

class DatatableSearchField {
  bool selected = false;
  final String label;
  final String field;
  final String operator;

  DatatableSearchField({
    this.selected = false,
    required this.label,
    required this.field,
    required this.operator,
  });

  void select() {
    selected = true;
  }
}

/// example:
/// <datatable-component [data]="solicitantes" [settings]="datatableSettings" [searchInFields]="searchInFields" (dataRequest)="onRequestData($event)"></datatable-component>
///
@Component(
  selector: 'datatable-component',
  styleUrls: ['datatable_component.css'],
  templateUrl: 'datatable_component.html',
  directives: [
    coreDirectives,
    formDirectives,
    DropdownMenuDirective,
    SafeInnerHtmlDirective,
  ],
  //changeDetection: ChangeDetectionStrategy.OnPush,
)
class DatatableComponent implements AfterChanges, AfterViewInit, OnDestroy {
  @Input()
  Filters dataTableFilter = Filters();

  @ViewChild('inputSearchElement')
  InputElement? inputSearchElement;

  @ViewChild('card')
  DivElement? card;

  @ViewChild('table')
  HtmlElement? table;

  final SimpleLoading _loading = SimpleLoading();

  void showLoading() {
    _loading.show(target: card);
  }

  void hideLoading() {
    _loading.hide();
  }

  int get getCurrentTotalItems {
    return dataTableFilter.offset! + dataTableFilter.limit!;
  }

  List<DatatableSearchField> _searchInFields = [];

  @Input('searchInFields')
  set searchInFields(List<DatatableSearchField> pFieldsS) {
    var v = pFieldsS;
    if (!(v.where((e) => e.selected == true).isNotEmpty == true)) {
      v.first.select();
    }
    var selectedSearchField = v.where((e) => e.selected == true).first;

    dataTableFilter.searchInFields = [
      FilterSearchField(
        active: true,
        field: selectedSearchField.field,
        operator: selectedSearchField.operator,
        label: selectedSearchField.label,
      )
    ];

    _searchInFields = v;
  }

  List<DatatableSearchField> get searchInFields => _searchInFields;

  @Input('limitPerPageOptions')
  List<int> limitPerPageOptions = [
    1,
    5,
    6,
    7,
    12,
    25,
    50,
    100,
    500,
    1000,
    2000
  ];

  int _defaultItemsPerPage = 12;

  @Input()
  // ignore: unnecessary_getters_setters
  set defaultItemsPerPage(int v) {
    _defaultItemsPerPage = v;
    dataTableFilter.limit = _defaultItemsPerPage;
  }

  // ignore: unnecessary_getters_setters
  int get defaultItemsPerPage => _defaultItemsPerPage;

  DatatableSettings _settings = DatatableSettings(colsDefinitions: []);

  @Input('settings')
  set settings(DatatableSettings d) {
    _settings = d;
  }

  DatatableSettings get settings {
    return _settings;
  }

  List<DatatableRow> rows = [];

  DataFrame _data = DataFrame(items: [], totalRecords: 0);

  @Input('data')
  set data(DataFrame d) {
    _data = d;
    totalRecords = _data.totalRecords;
    draw();
  }

  @Input()
  bool nullIsEmpty = true;

  /// remove one element of DatatableComponent and return index of this element
  int removeItem(dynamic element) {
    var idx = _data.removeItem(element);
    rows.remove(rows[idx]);
    return idx;
  }

  void update() {
    draw();
    //drawPagination();
  }

  void draw() {
    //print('draw');
    rows.clear();

    if (settings.colsDefinitions.isEmpty == true) {
      print(
          'DataTable settings is null. Define settings like: <datatable-component [settings]="datatableSettings"');
      return;
    }

    for (var i = 0; i < _data.itemsAsMap.length; i++) {
      var itemMap = _data.itemsAsMap[i];
      var itemInstance = _data[i];
      var row = DatatableRow(index: i, instance: itemInstance, columns: []);
      //for (final colDefinition in _settings.colsDefinitions) {
      for (var j = 0; j < _settings.colsDefinitions.length; j++) {
        var colDefinition = _settings.colsDefinitions[j];
        dynamic value;
        if (colDefinition.key.contains('||')) {
          var keys =
              colDefinition.key.split('||').map((k) => k.trim()).toList();
          value = keys
              .map((key) => itemMap[key])
              .join(colDefinition.multiValSeparator);
        } else {
          if (colDefinition.key.contains('.')) {
            var keys = colDefinition.key.split('.');
            value = getValRecursive(itemMap, keys);
          } else {
            value = itemMap[colDefinition.key];
          }
        }
        if (colDefinition.customRender != null) {
          value = colDefinition.customRender!(itemMap, itemInstance);
        } else if (colDefinition.format != null) {
          //date

          switch (colDefinition.format) {
            case DatatableFormat.date:
              if (value != null) {
                value = value is DateTime
                    ? value
                    : DateTime.tryParse(value!.toString());
                final formatter = DateFormat('dd/MM/yyyy');
                value = formatter.format(value);
              }
              break;
            case DatatableFormat.dateTime:
              if (value != null) {
                value = value is DateTime
                    ? value
                    : DateTime.tryParse(value!.toString());
                final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
                value = formatter.format(value);
              }
              break;
            case DatatableFormat.text:
              value = value?.toString();
              break;
            case null:
              value = '';
              break;
          }
        }
        if (nullIsEmpty == true) {
          value = value == null ? '' : value.toString();
        }
        row.addColumn(DatatableCol(
          value: value,
          key: colDefinition.key,
          title: colDefinition.title,
          visibility: colDefinition.visibility,
        ));
      }
      rows.add(row);
    }
  }

  dynamic getValRecursive(Map<String, dynamic> itemMap, List<String> keys) {
    var k = keys[0];
    if (keys.length > 1) {
      keys.remove(k);
      var map = itemMap[k];
      if (map is Map<String, dynamic>) {
        return getValRecursive(map, keys);
      } else {
        return map;
      }
    } else {
      return itemMap[k];
    }
  }

  DataFrame get data {
    return _data;
  }

  @Input('searchLabel')
  String searchLabel = 'Busca';

  @Input('searchPlaceholder')
  String searchPlaceholder = 'Digite para buscar';

  @Input()
  String totalRecordsLabel = 'Total:';

// -------------------------------- pagination --------------------------------
  int totalRecords = 0;
  int _currentPage = 1;
  final int _btnQuantity = 5;
  PaginationType paginationType = PaginationType.carousel;
  List<PaginationItem> paginationItems = <PaginationItem>[];

  @override
  void ngAfterViewInit() {
    drawPagination();
    //print('DatatableComponent@ngAfterViewInit');
  }

  @override
  void ngAfterChanges() {
    //draw();
    drawPagination();
    // print('DatatableComponent@ngAfterChanges');
  }

  int get numPages {
    var totalPages = (totalRecords / dataTableFilter.limit!).ceil();
    return totalPages;
  }

  void drawPagination() {
    // print('drawPagination');
    //quantidade total de paginas
    var totalPages = numPages;

    //quantidade de botões de paginação exibidos
    var btnQuantity = _btnQuantity > totalPages ? totalPages : _btnQuantity;
    var currentPage = _currentPage; //pagina atual
    //clear paginateContainer for new draws
    paginationItems.clear();
    if (totalRecords < dataTableFilter.limit!) {
      return;
    }

    if (btnQuantity == 1) {
      return;
    }

    var paginatePrevBtn = PaginationItem(
      id: 'DataTables_Table_0_previous',
      cssClasses: ['paginate_button', 'previous'],
      label: '←',
      paginationButtonType: PaginationButtonType.prev,
      action: prevPage,
    );

    if (currentPage == 1) {
      paginatePrevBtn.removeClass('disabled');
      paginatePrevBtn.addClass('disabled');
    }
    paginationItems.add(paginatePrevBtn);

    var paginateNextBtn = PaginationItem(
      id: 'DataTables_Table_0_next',
      cssClasses: ['paginate_button', 'next'],
      label: '→',
      paginationButtonType: PaginationButtonType.next,
      action: nextPage,
    );

    if (currentPage == totalPages) {
      paginateNextBtn.removeClass('disabled');
      paginateNextBtn.addClass('disabled');
    }

    var idx = 0;
    var loopEnd = 0;

    switch (paginationType) {
      case PaginationType.carousel:
        idx = (currentPage - (btnQuantity / 2)).toInt();
        if (idx <= 0) {
          idx = 1;
        }
        loopEnd = idx + btnQuantity;
        if (loopEnd > totalPages) {
          loopEnd = totalPages + 1;
          idx = loopEnd - btnQuantity;
        }
        while (idx < loopEnd) {
          var paginateBtn = PaginationItem(
            action: () {},
            cssClasses: ['paginate_button', if (idx == currentPage) 'current'],
            label: idx.toString(),
          );

          paginateBtn.action = () {
            var index = int.parse(paginateBtn.label);
            if (_currentPage != index) {
              _currentPage = index;
              changePage(_currentPage);
            }
          };
          paginationItems.add(paginateBtn);

          idx++;
        }
        break;
      case PaginationType.cube:
        var facePosition = (currentPage % btnQuantity) == 0
            ? btnQuantity
            : currentPage % btnQuantity;
        loopEnd = btnQuantity - facePosition + currentPage;
        idx = currentPage - facePosition;
        while (idx < loopEnd) {
          idx++;
          if (idx <= totalPages) {
            var paginateBtn = PaginationItem(
              action: () {},
              cssClasses: [
                'paginate_button',
                if (idx == currentPage) 'current'
              ],
              label: idx.toString(),
            );

            paginateBtn.action = () {
              var index = int.parse(paginateBtn.label);
              if (_currentPage != index) {
                _currentPage = index;
                changePage(_currentPage);
              }
            };

            paginationItems.add(paginateBtn);
          }
        }
        break;
    }
    paginationItems.add(paginateNextBtn);
  }

  void prevPage() {
    if (_currentPage == 0) {
      return;
    }
    if (_currentPage > 1) {
      _currentPage--;
      changePage(_currentPage);
    }
  }

  void nextPage() {
    if (_currentPage == numPages) {
      return;
    }
    if (_currentPage < numPages) {
      _currentPage++;
      changePage(_currentPage);
    }
  }

  void changePage(page) {
    onRequestData();
    if (page != _currentPage) {
      _currentPage = page;
    }
  }

// -------------------------------- fim /pagination --------------------------------

  final _dataRequest = StreamController<Filters>();

  //evento dataRequest
  @Output()
  Stream<Filters> get dataRequest => _dataRequest.stream;

  bool isLoading = true;

  void onRequestData() {
    isLoading = true;
    var currentPage = _currentPage == 1 ? 0 : _currentPage - 1;
    dataTableFilter.offset = currentPage * dataTableFilter.limit!;
    _dataRequest.add(dataTableFilter);
  }

// ---------------- event to change the amount of items displayed per page ----------------
  final _limitChangeRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get limitChange => _limitChangeRequest.stream;

  void changeItemsPerPageHandler(SelectElement select) {
    var li = int.tryParse(select.selectedOptions.first.value);
    _currentPage = 1;
    dataTableFilter.limit = li;
    _limitChangeRequest.add(dataTableFilter);
    onRequestData();
  }

// ---------------- evento de busca ----------------
  final _searchRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get searchRequest => _searchRequest.stream;

  void onSearch(String? searchString) {
    dataTableFilter.searchString = searchString;
    _searchRequest.add(dataTableFilter);
    onRequestData();
  }

  @Input()
  bool disableSearchEvent = false;

  void handleSearchInputKeypress(e, String? searchString) {
    //e.preventDefault();
    if (disableSearchEvent != true) {
      e.stopPropagation();
      if (e.keyCode == KeyCode.ENTER) {
        onSearch(searchString);
      }
    }
  }

  void handleSearchFieldSelectChange(event, String? index) {
    if (index != null) {
      var selectedSearchField = _searchInFields[int.parse(index)];
      //print('handleSearchFieldSelectChange $selectedSearchField');
      dataTableFilter.searchInFields = [
        FilterSearchField(
          active: true,
          field: selectedSearchField.field,
          operator: selectedSearchField.operator,
          label: selectedSearchField.label,
        )
      ];
    }
  }

// ---------------- evento quando clicar em uma row ----------------
  final _onRowClickStreamController = StreamController<dynamic>();

  /// event dispatched on row click
  ///```html
  ///<datatable-component
  ///      [settings]="datatableSettings"
  ///      [data]="procedimentos"
  ///      (dataRequest)="onDataRequest($event)"
  ///       (rowClick)="onRowClick($event)">
  ///</datatable-component>
  ///```
  @Output()
  Stream<dynamic> get onRowClick => _onRowClickStreamController.stream;

  void rowClickHandler(DatatableRow row) {
    //var item = _data[row.index];
    _onRowClickStreamController.add(row.instance);
  }

// ---------------- evento de selecionar items ----------------

  @Input()
  bool showCheckboxToSelectRow = true;

  final _selectAllStreamController = StreamController<List<dynamic>>();

  @Output()
  Stream<List<dynamic>> get selectAll => _selectAllStreamController.stream;

  List<T> getAllSelected<T>() => rows
      .where((e) => e.selected)
      .toList()
      .map<T>((e) => e.instance as T)
      .toList();

  //quando selecionar tudos os items
  bool isSelectAll = false;
  void onSelectAll(event) {
    isSelectAll = !isSelectAll;
    if (isSelectAll == true) {
      rows.forEach((row) {
        row.selected = true;
      });
    } else {
      unSelectAll();
    }
    _selectAllStreamController.add(
        rows.where((e) => e.selected).toList().map((e) => e.instance).toList());
  }

  void unSelectAll() {
    rows.forEach((row) {
      row.selected = false;
    });
  }

  final _selectStreamController = StreamController<dynamic>();

  @Output()
  Stream<dynamic> get select => _selectAllStreamController.stream;

  //quando selecionar um item
  void onSelect(MouseEvent event, DatatableRow item) {
    event.stopPropagation();
    item.selected = !item.selected;
    if (item.selected) {
      _selectStreamController.add(item.instance);
    }
  }

// ---------------- evento de ordenação ----------------
  @Input()
  bool enableGlobalSorting = true;

  String _orderDir = 'asc';
  HtmlElement? lastTitleCell; //TableCellElement

  void onOrder(DatatableCol colDefinition, HtmlElement currentTitleCell) {
    if (enableGlobalSorting == true) {
      if (colDefinition.enableSorting && colDefinition.sortingBy != null) {
        if (lastTitleCell != null) {
          lastTitleCell?.classes.removeAll(['sorting_asc', 'sorting_desc']);
          lastTitleCell?.classes.add('sorting');
        }
        if (_orderDir == 'asc') {
          _orderDir = 'desc';
        } else if (_orderDir == 'desc') {
          _orderDir = 'asc';
        }

        dataTableFilter.orderBy = colDefinition.sortingBy;
        dataTableFilter.orderDir = _orderDir;

        if (dataTableFilter.orderDir == 'desc' &&
            currentTitleCell.getAttribute('data-key') ==
                dataTableFilter.orderBy) {
          currentTitleCell.classes.remove('sorting');
          currentTitleCell.classes.remove('sorting_asc');
          currentTitleCell.classes.add('sorting_desc');
        }
        if (dataTableFilter.orderDir == 'asc' &&
            currentTitleCell.getAttribute('data-key') ==
                dataTableFilter.orderBy) {
          currentTitleCell.classes.remove('sorting');
          currentTitleCell.classes.remove('sorting_desc');
          currentTitleCell.classes.toggle('sorting_asc');
        }
        lastTitleCell = currentTitleCell;
        onRequestData();
      }
    }
  }

  // ----------------------
  void changeVisibilityOfCol(DatatableCol col) {
    col.visibility = !col.visibility;

    rows.forEach((row) {
      row.columns.forEach((column) {
        if (column.key == col.key) {
          column.visibility = col.visibility;
        }
      });
    });
  }

  @override
  void ngOnDestroy() {
    _selectStreamController.close();
    _selectAllStreamController.close();
    _onRowClickStreamController.close();
    _searchRequest.close();
    _limitChangeRequest.close();
    _dataRequest.close();
  }
}
