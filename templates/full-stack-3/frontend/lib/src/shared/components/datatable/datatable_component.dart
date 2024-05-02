import 'dart:async';
import 'dart:html';
import 'package:intl/intl.dart';

import 'package:sibem_frontend/sibem_frontend.dart';

import 'pagination_item.dart';
import 'dart:js_util' as js_util;
import 'package:dart_excel/dart_excel.dart';

// import 'package:pdf_fork/pdf.dart' as pdf;
// import 'package:pdf_fork/widgets.dart' as pdf;
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdf;

extension CssStyleDeclarationExtension on CssStyleDeclaration {
  /// rowGap
  String get gridRowGap {
    //var result = js_util.callMethod(this, 'gridRowGap', []);
    var result = js_util.getProperty(this, 'gridRowGap');
    return result.toString();
  }
}

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

/// Example:
/// <datatable-component [dataTableFilter]="filtros" [data]="pessoas" [settings]="datatableSettings" [searchInFields]="searchInFields"
///			(dataRequest)="onRequestData($event)"></datatable-component>
///
/// DataFrame<CgmFull> pessoas = DataFrame(items: [], totalRecords: 0);
///
/// DatatableSettings datatableSettings = DatatableSettings(colsDefinitions: [
///   DatatableCol(key: 'nom_cgm', title: 'Nome'),
///   DatatableCol(key: 'numcgm', title: 'Código'),
///   DatatableCol(key: 'documento', title: 'Documento', visibility: false),
///   DatatableCol(key: 'nom_fantasia', title: 'Nome Fantasia', visibility: false),
/// ]);
///
/// List<DatatableSearchField> searchInFields = <DatatableSearchField>[
///   DatatableSearchField(field: 'nom_cgm', operator: 'like', label: 'Nome'),
///   DatatableSearchField(field: 'sw_cgm.numcgm', operator: '=', label: 'CGM'),
///   DatatableSearchField(field: 'cpf', operator: 'like', label: 'CPF'),
///   DatatableSearchField(field: 'cnpj', operator: 'like', label: 'CNPJ'),
///   DatatableSearchField(
///       field: 'nom_fantasia', operator: 'like', label: 'Nome Fantasia'),
/// ];
///
/// Filters filtros = Filters(limit: 12, offset: 0);
///
/// Future<void> load() async {
///   try {
///     _simpleLoading.show(target: containerElement);
///     pessoas = await _cgmService.all(filtros);
///   } catch (e, s) {
///     print('ConsultarCgmPage@load $e $s');
///   } finally {
///     _simpleLoading.hide();
///   }
/// }
///
///
/// void onRequestData(Filters dtf) {
///   load();
/// }
@Component(
    selector: 'datatable-component',
    styleUrls: ['datatable_component.css', 'grid.css'],
    templateUrl: 'datatable_component.html',
    directives: [
      coreDirectives,
      formDirectives,
      DropdownMenuDirective,
      SafeInnerHtmlDirective,
      SafeAppendHtmlDirective,
    ],
    //changeDetection: ChangeDetectionStrategy.OnPush,
    exports: [DatatableRowType])
class DatatableComponent implements AfterChanges, AfterViewInit, OnDestroy {
  @Input()
  Filters dataTableFilter = Filters();
  final Element rootElement;
  DatatableComponent(this.rootElement);

  //@ViewChild('inputSearchElement')
  //InputElement? inputSearchElement;
//data-table-search-field
  InputElement? get inputSearchElement =>
      rootElement.querySelector('.data-table-search-field') as InputElement?;

  void setInputSearchFocus() {
    inputSearchElement?.focus();
  }

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
    10,
    12,
    20,
    24,
    25,
    //50,
    // 100,
    // 500,
    // 1000,
    // 2000
  ];

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

  @Input('gridMode')
  bool gridMode = false;

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

    String? anterior;
    for (var i = 0; i < _data.itemsAsMap.length; i++) {
      final itemMap = _data.itemsAsMap[i];
      final itemInstance = _data[i];
      final row = DatatableRow(index: i, instance: itemInstance, columns: []);

      for (var j = 0; j < _settings.colsDefinitions.length; j++) {
        final colDefinition = _settings.colsDefinitions[j];
        dynamic value;
        // pega o valor de forma recursiva caso haja um separador
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
        if (colDefinition.customRenderString != null) {
          value = colDefinition.customRenderString!(itemMap, itemInstance);
        } else if (colDefinition.format != null) {
          switch (colDefinition.format) {
            case DatatableFormat.bool:
              if (value is bool) {
                value = value ? 'Sim' : 'Não';
              }
              break;
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

        Element? htmlElement;
        if (colDefinition.customRenderHtml != null) {
          htmlElement = colDefinition.customRenderHtml!(itemMap, itemInstance);
          value = '';
        }

        var column = DatatableCol(
          value: value,
          key: colDefinition.key,
          title: colDefinition.title,
          visibility: colDefinition.visibility,
          htmlElement: htmlElement,
          enableGrouping: colDefinition.enableGrouping,
          groupByKey: colDefinition.groupByKey,
          visibilityOnCard: colDefinition.visibilityOnCard,
          showTitleOnCard: colDefinition.showTitleOnCard,
          showAsFooterOnCard: colDefinition.showAsFooterOnCard,
        );

        row.addColumn(column);
      }
      // implementação do agrupamento
      if (settings.enableGrouping) {
        var groupingColumns = row.columns
            .where((el) => el.enableGrouping && el.groupByKey != null);

        var groupBys = groupingColumns.map((e) => e.groupByKey!).toList();

        if (groupBys.isNotEmpty) {
          var atual = _data.itemsAsMap[i].entries
              .where((map) => groupBys.contains(map.key))
              .map((m) => m.value)
              .join('.');
          if ((i - 1) >= 0) {
            anterior = _data.itemsAsMap[i - 1].entries
                .where((map) => groupBys.contains(map.key))
                .map((m) => m.value)
                .join('.');
          }

          //print(' separador $atual | $anterior');
          if (atual != anterior) {
            var divTitle = DivElement();
            divTitle.text =
                groupingColumns.map((e) => e.value).join('      /     ');
            rows.add(DatatableRow(type: DatatableRowType.groupTitle, columns: [
              DatatableCol(
                type: DatatableColType.groupTitle,
                htmlElement: divTitle,
                key: '',
                title: '',
                visibility: true,
                colspan: row.columns.length,
                styleCss: 'text-align: center;background: #F3F4F6;',
              )
            ]));
            rows.add(row);
          } else {
            rows.add(row);
          }
        }
      } else {
        rows.add(row);
      }
    }
  }

  void gridMasonry(String selector) {
    var gridItems = document.querySelectorAll(selector);

    if (gridItems.isNotEmpty &&
        gridItems[0].getComputedStyle().gridTemplateRows != 'masonry') {
      var grids = gridItems.map((grid) {
        var items = grid.childNodes
            .where((child) {
              return child.nodeType == Node.ELEMENT_NODE &&
                  double.tryParse((child as Element)
                          .getComputedStyle()
                          .gridColumnEnd) !=
                      -1;
            })
            .map((e) => e as Element)
            .toList();

        var rowGap =
            double.parse(grid.getComputedStyle().gap.replaceFirst('px', ''));

        return {
          '_el': grid,
          'gap': rowGap,
          'items': items,
          'ncol': 0,
        };
      }).toList();

      for (var grid in grids) {
        // get the post relayout number of columns
        int ncol = (grid['_el'] as Element)
            .getComputedStyle()
            .gridTemplateColumns
            .split(' ')
            .length;

        // if the number of columns has changed
        if (grid['ncol'] != ncol) {
          // update number of columns
          grid['ncol'] = ncol;

          // revert to initial positioning, no margin
          for (var c in (grid['items'] as List)) {
            c.style.removeProperty('margin-top');
          }

          // if we have more than one column
          if ((grid['ncol'] as int) > 1) {
            var items = (grid['items'] as List<Element>);
            var sublist = items.sublist(ncol);
            for (var i = 0; i < sublist.length; i++) {
              var c = sublist[i];
              // bottom edge of item above | borda inferior do item acima
              var prevFin = items[i].getBoundingClientRect().bottom;
              // top edge of current item
              var currIni = c.getBoundingClientRect().top;

              var marginTop =
                  '${prevFin + (grid['gap'] as double) - currIni}px';

              c.style.marginTop = marginTop;
            }
          }
        }
      }
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

  @Input('emptyListLabel')
  String emptyListLabel = 'Vazio...';

  @Input('searchPlaceholder')
  String searchPlaceholder = 'Digite para buscar';

  @Input()
  String totalRecordsLabel = 'Total:';

// -------------------------------- pagination --------------------------------
  int totalRecords = 0;
  int _currentPage = 1;

  int get getCurrentPage => _currentPage;

  final int _btnQuantity = 5;
  PaginationType paginationType = PaginationType.carousel;
  List<PaginationItem> paginationItems = <PaginationItem>[];

  @override
  void ngAfterViewInit() {
    drawPagination();
    //print('DatatableComponent@ngAfterViewInit');
  }

  /// muda de modo lista ou grade
  void changeViewMode() {
    gridMode = !gridMode;
    // if (gridMode) {
    //   Future.delayed(Duration(milliseconds: 200), () {
    //     gridMasonry('.grid-layout');
    //   });
    // }
  }

  @override
  void ngAfterChanges() {
    //draw();
    drawPagination();
    // print('DatatableComponent@ngAfterChanges');
  }

  /// total de paginas
  int get numPages {
    final totalPages = (totalRecords / dataTableFilter.limit!).ceil();
    return totalPages;
  }

  void drawPagination() {
    // print('drawPagination');
    //quantidade total de paginas
    final totalPages = numPages;

    //quantidade de botões de paginação exibidos
    final btnQuantity = _btnQuantity > totalPages ? totalPages : _btnQuantity;
    final currentPage = _currentPage; //pagina atual
    //clear paginateContainer for new draws
    paginationItems.clear();
    if (totalRecords < dataTableFilter.limit!) {
      return;
    }

    if (btnQuantity == 1) {
      return;
    }

    var paginatePrevBtn = PaginationItem(
      //id: 'DataTables_Table_0_previous',
      cssClasses: ['paginate_button', 'page-item', 'previous'],
      label: '←',
      paginationButtonType: PaginationButtonType.prev,
      action: prevPage,
    );

    if (currentPage == 1) {
      paginatePrevBtn.removeClass('disabled');
      paginatePrevBtn.addClass('disabled');
    }
    paginationItems.add(paginatePrevBtn);

    final paginateNextBtn = PaginationItem(
      //id: 'DataTables_Table_0_next',
      cssClasses: ['paginate_button', 'page-item', 'next'],
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
          final paginateBtn = PaginationItem(
            action: () {},
            cssClasses: [
              'paginate_button',
              'page-item',
              if (idx == currentPage) 'active'
            ],
            label: idx.toString(),
          );

          paginateBtn.action = () {
            final index = int.parse(paginateBtn.label);
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
        final facePosition = (currentPage % btnQuantity) == 0
            ? btnQuantity
            : currentPage % btnQuantity;
        loopEnd = btnQuantity - facePosition + currentPage;
        idx = currentPage - facePosition;
        while (idx < loopEnd) {
          idx++;
          if (idx <= totalPages) {
            final paginateBtn = PaginationItem(
              action: () {},
              cssClasses: [
                'paginate_button',
                'page-item',
                if (idx == currentPage) 'active'
              ],
              label: idx.toString(),
            );

            paginateBtn.action = () {
              final index = int.parse(paginateBtn.label);
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

  void changePage(int page) {
    onRequestData();
    if (page != _currentPage) {
      _currentPage = page;
    }
  }

  void irParaUltimaPagina() {
    final lastPage = numPages;
    _currentPage = lastPage;
    changePage(lastPage);
  }

  void irParaPrimeiraPagina() {
    _currentPage = 1;
    changePage(1);
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
    //esperimental
    _settings.setOrdemStartIndex(dataTableFilter.offset!);

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
    //onRequestData();
  }

// ---------------- evento de busca ----------------
  final _searchRequest = StreamController<Filters>();

  @Output()
  Stream<Filters> get searchRequest => _searchRequest.stream;

  void onSearch() {
    _currentPage = 1;
    _searchRequest.add(dataTableFilter);
    onRequestData();
  }

  @Input()
  bool disableSearchEvent = false;

  @Input()
  bool disableHeaderPadding = false;

  @Input()
  bool disableHeader = false;

  @Input()
  bool disableFooter = false;

  @Input()
  bool disableRowClick = false;

  void handleSearchInputKeypress(e) {
    //e.preventDefault();
    if (disableSearchEvent != true) {
      e.stopPropagation();
      if (e.keyCode == KeyCode.ENTER) {
        onSearch();
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
  ///       (onRowClick)="onRowClick($event)">
  ///</datatable-component>
  ///```
  @Output()
  Stream<dynamic> get onRowClick => _onRowClickStreamController.stream;

  void rowClickHandler(DatatableRow row) {
    if (disableRowClick == false) {
      if (_onRowClickStreamController.isClosed == false) {
        if (row.type == DatatableRowType.normal) {
          _onRowClickStreamController.add(row.instance);
        }
      }
    }
  }

// ---------------- evento de selecionar items ----------------

  /// if true not show Checkbox on each row
  ///  <datatable-component
  ///      [settings]="datatableSettings"
  ///      [data]="procedimentos"
  ///      (dataRequest)="onDataRequest($event)"
  ///       (onRowClick)="onRowClick($event)"
  ///     [showCheckboxToSelectRow]="true">
  ///</datatable-component>
  @Input()
  bool showCheckboxToSelectRow = true;

  final _selectAllStreamController = StreamController<List<dynamic>>();

  @Output()
  Stream<List<dynamic>> get selectAll => _selectAllStreamController.stream;

  /// obter todos os selecionados
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
      for (var row in rows) {
        row.selected = true;
      }
    } else {
      unSelectAll();
    }
    _selectAllStreamController.add(
        rows.where((e) => e.selected).toList().map((e) => e.instance).toList());
  }

  void unSelectAll() {
    for (var row in rows) {
      row.selected = false;
    }
  }

  void unSelectItemInstance(item) {
    for (var row in rows) {
      if (row.instance == item) {
        row.selected = false;
      }
    }
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
          // currentTitleCell.classes.remove('sorting');
          currentTitleCell.classes.remove('sorting_asc');
          currentTitleCell.classes.add('sorting_desc');
        }
        if (dataTableFilter.orderDir == 'asc' &&
            currentTitleCell.getAttribute('data-key') ==
                dataTableFilter.orderBy) {
          // currentTitleCell.classes.remove('sorting');
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
    col.visibilityOnCard = col.visibility;

    for (var row in rows) {
      for (var column in row.columns) {
        if (column.key == col.key) {
          column.visibility = col.visibility;
          column.visibilityOnCard = col.visibilityOnCard;
        }
      }
    }
  }

  /// exportar para Excel
  void exportXlsx() {
    // Create a new Excel document.
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    if (rows.isNotEmpty) {
      sheet.importList(
          rows.first.columns.map((e) => e.title).toList(), 1, 1, false);

      for (var i = 1; i < rows.length + 1; i++) {
        final col = rows[i - 1];

        int firstRow = i + 1;
        int firstColumn = 1;

        sheet.importList(col.columns.map((e) => e.value).toList(), firstRow,
            firstColumn, false);
      }

      sheet
          .getRangeByIndex(1, 1, rows.length, rows.first.columns.length)
          .autoFitColumns();
    }
    // sheet.getRangeByName('A1').setText('Hello World');
    // sheet.getRangeByName('A3').setNumber(44);
    // sheet.getRangeByName('A5').setDateTime(DateTime(2020, 12, 12, 1, 10, 20));

    // Save doc.
    final List<int> bytes = workbook.saveAsStream();

    FrontUtils.download(
        bytes,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'Relatório.xlsx');
    //Dispose workbook
    workbook.dispose();
  }

  Future<void> exportPdf([bool isPrint = false, bool isDownload = true]) async {
    final loading = SimpleLoading();
    loading.show();
    try {
      final logoUrlSvg = '/assets/images/brasao_editado_1.svg';
      final svgRaw = await FrontUtils.getNetworkTextFile(logoUrlSvg);
      final svgImageLogo = pdf.SvgImage(svg: svgRaw);
      final docPdf = pdf.Document();
      final now = DateTime.now();

      final headerTextStyle =
          pdf.TextStyle(fontSize: 10, color: pdf.PdfColor.fromInt(0xff2c3e50));

      //visibility
      final tableItems = <List<String>>[];
      tableItems.add(settings.colsDefinitions
          .where((c) => c.visibility)
          .map((e) => e.title)
          .toList());

      tableItems.addAll(rows.map((row) => row.columns
          .where((c) => c.visibility)
          .map((col) => col.value)
          .toList()));

      docPdf.addPage(
        pdf.MultiPage(
          orientation: pdf.PageOrientation.landscape,
          pageFormat: pdf.PdfPageFormat.a4.copyWith(
            marginTop: 1.0 * pdf.PdfPageFormat.cm,
            marginLeft: 1.0 * pdf.PdfPageFormat.cm,
            marginRight: 1.0 * pdf.PdfPageFormat.cm,
            marginBottom: 1.0 * pdf.PdfPageFormat.cm,
          ),
          crossAxisAlignment: pdf.CrossAxisAlignment.start,
          header: (pdf.Context context) {
            return pdf.Padding(
                padding: pdf.EdgeInsets.only(bottom: 10),
                child: pdf.Row(
                  mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
                  children: [
                    pdf.Column(
                      children: [
                        pdf.Text('office Municipal de city',
                            style: headerTextStyle),
                        pdf.Text(
                            'Rua Campo do Albacora, nº 75 - Loteamento Atlântica',
                            style: headerTextStyle),
                        pdf.Text('CEP: 28895-664 | Tel.: (22) 2771-1515',
                            style: headerTextStyle),
                        pdf.Text(
                            '''Emissão: ${DateFormat("dd/MM/yyyy 'às' HH:mm").format(now)}   |   Página: ${context.pageNumber} de ${context.pagesCount}''',
                            style: headerTextStyle),
                      ],
                      crossAxisAlignment: pdf.CrossAxisAlignment.start,
                    ),
                    pdf.SizedBox(
                      height: 70,
                      width: 140,
                      child: svgImageLogo, //svgImage, //Image(imageLogo),
                    )
                  ],
                ));
          },
          build: (pdf.Context context) => <pdf.Widget>[
            pdf.Header(
              level: 1,
              text: 'Relatório',
              margin: pdf.EdgeInsets.only(bottom: 1.0 * pdf.PdfPageFormat.mm),
              padding: pdf.EdgeInsets.only(bottom: 0.0 * pdf.PdfPageFormat.mm),
              decoration: pdf.BoxDecoration(),
            ),
            pdf.TableHelper.fromTextArray(context: context, data: tableItems),
          ],
          footer: (pdf.Context context) {
            return pdf.Container(
              width: double.infinity,
              decoration: pdf.BoxDecoration(
                  border: pdf.Border(
                      top: pdf.BorderSide(color: pdf.PdfColors.grey))),
              child: pdf.Padding(
                padding: pdf.EdgeInsets.only(top: 5),
                child: pdf.Text('Sistema Rava - ${DateTime.now().year}',
                    style:
                        pdf.TextStyle(fontSize: 9, color: pdf.PdfColors.grey)),
              ),
            );
          },
        ),
      );

      //save PDF
      final bytes = await docPdf.save();
      if (isDownload) {
        FrontUtils.download(bytes, 'application/pdf', 'Relatório.pdf');
      }
      if (isPrint) {
        FrontUtils.printFileBytes(bytes, 'application/pdf');
      }
    } catch (e) {
      print('Erro ao gerar PDF $e');
    } finally {
      loading.hide();
    }
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
