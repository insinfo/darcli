import 'dart:async';

import 'dart:html' as html;

import 'package:esic_core/esic_core.dart';
import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

/// <pagination-component [totalRecords]="10"> </pagination-component>
@Component(
    selector: 'pagination-component',
    styleUrls: ['pagination.css'],
    directives: [coreDirectives, formDirectives],
    templateUrl: 'pagination.html',
    exports: [
      PaginationItem,
    ])
class PaginationComponent implements AfterChanges {
  var filters = Filters();

  final _onChangePageSC = StreamController<Filters>();

  @Output()
  Stream<Filters> get onChangePage => _onChangePageSC.stream;

  void changePageHandle() {
    filters.offset = (_currentPage == 1 ? 0 : _currentPage - 1) * limitPerPage;
    filters.limit = limitPerPage;
    _onChangePageSC.add(filters);
    drawPagination();
  }

  // Evento acionado quando avança uma página
  //final _nextPageStreamController = StreamController<DataTableFilter>();

  //@Output()
  //Stream<DataTableFilter> get nextPageStream => _nextPageStreamController.stream;

  @override
  void ngAfterChanges() {
    drawPagination();
  }

  /// ********** PAGINATION BLOCK **************/

  @ViewChild('firstButton')
  html.HtmlElement? firstButton;

  @ViewChild('prevButton')
  html.HtmlElement? prevButton;

  @ViewChild('nextButton')
  html.HtmlElement? nextButton;

  @ViewChild('lastButton')
  html.HtmlElement? lastButton;

  int btnQuantity = 3;

  @Input('limitPerPage')
  int limitPerPage = 12; // itens por página

  int _totalRecords = 0;

  @Input('totalRecords')
  set totalRecords(int v) {
    _totalRecords = v;
    //print(' set totalRecords $v');
  }

  int get totalRecords => _totalRecords;

  var offset = 0;
  var _currentPage = 1;

  List<PaginationItem> paginationItems = <PaginationItem>[];

  int getCurrentPage() {
    return _currentPage;
  }

  int getNumPages() {
    var totalPages = (_totalRecords / limitPerPage).ceil();
    return totalPages;
  }

  void firstPage(e) {
    if (_currentPage == 0) {
      return;
    }
    if (_currentPage > 1) {
      _currentPage = 1;
      changePage(_currentPage);
    }
  }

  void prevPage(e) {
    if (_currentPage == 0) {
      return;
    }
    if (_currentPage > 1) {
      _currentPage--;
      changePage(_currentPage);
    }
  }

  void nextPage(e) {
    if (_currentPage == getNumPages()) {
      return;
    }
    if (_currentPage < getNumPages()) {
      _currentPage++;
      changePage(_currentPage);
    }
  }

  void lastPage(e) {
    if (_currentPage == getNumPages()) {
      return;
    }
    if (_currentPage < getNumPages()) {
      _currentPage = getNumPages();
      changePage(_currentPage);
    }
  }

  void changePage(page) {
    changePageHandle();
    if (page != _currentPage) {
      _currentPage = page;
    }
  }

  Future<void> drawPagination() async {
    await Future.delayed(Duration(milliseconds: 100));

    var totalPages = getNumPages();

    paginationItems.clear();

    if (_currentPage == 1 && totalPages > 1) {
      firstButton?.parent?.classes.add('disabled');
      prevButton?.parent?.classes.add('disabled');
      nextButton?.parent?.classes.remove('disabled');
      lastButton?.parent?.classes.remove('disabled');
    } else if (_currentPage == totalPages && totalPages > 1) {
      firstButton?.parent?.classes.remove('disabled');
      prevButton?.parent?.classes.remove('disabled');
      nextButton?.parent?.classes.add('disabled');
      lastButton?.parent?.classes.add('disabled');
    } else if (_currentPage != totalPages && totalPages > 1) {
      firstButton?.parent?.classes.remove('disabled');
      prevButton?.parent?.classes.remove('disabled');
      nextButton?.parent?.classes.remove('disabled');
      lastButton?.parent?.classes.remove('disabled');
    } else if (_currentPage == 1 && totalPages <= 1) {
      firstButton?.parent?.classes.add('disabled');
      prevButton?.parent?.classes.add('disabled');
      nextButton?.parent?.classes.add('disabled');
      lastButton?.parent?.classes.add('disabled');
    }

    //if (_totalRecords <= limitPerPage) {
    //  firstButton?.hidden = true;
    //  prevButton?.hidden = true;
    //  nextButton?.hidden = true;
    //  lastButton?.hidden = true;
    //   return;
    // } else {
    firstButton?.hidden = false;
    prevButton?.hidden = false;
    nextButton?.hidden = false;
    lastButton?.hidden = false;
    // }

    var idx = 0;
    var loopEnd = 0;
    idx = (_currentPage - (btnQuantity / 2)).toInt();
    if (idx <= 0) {
      idx = 1;
    }
    loopEnd = idx + btnQuantity;
    if (loopEnd > totalPages) {
      loopEnd = totalPages + 1;
      idx = loopEnd - btnQuantity;
    }
    while (idx < loopEnd) {
      var link = PaginationItem(
        label: idx.toString(),
        isActive: idx == _currentPage,
        action: () {
          if (_currentPage != idx) {
            _currentPage = idx;
            changePage(_currentPage);
          }
        },
      );

      if (idx > 0) {
        paginationItems.add(link);
      }
      idx++;
    }
  }

  void reset() {
    _currentPage = 1;
    drawPagination();
  }

  /// ********** FIM PAGINATION BLOCK **************/

}
