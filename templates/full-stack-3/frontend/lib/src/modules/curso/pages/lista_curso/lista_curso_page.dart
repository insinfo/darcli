import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de cursos
@Component(
  selector: 'lista-curso-page',
  templateUrl: 'lista_curso_page.html',
  styleUrls: ['lista_curso_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
  exports: [RoutePaths],
)
class ListaCursoPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final CursoService _cursoService;
  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  final html.Element hostElement;

  ListaCursoPage(this.notificationComponentService, this.hostElement,
      this._cursoService, this._router);

  var itemSelected = Curso(nome: '', id: -1, tipoCurso: '');

  final filtro = Filters(limit: 12, offset: 0);

  DataFrame<Curso> items = DataFrame<Curso>.newClear();

  DatatableSettings dtSettings = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', sortingBy: 'id', enableSorting: true),
    DatatableCol(
        key: 'nome', title: 'Nome', sortingBy: 'nome', enableSorting: true),
    DatatableCol(
        key: 'tipoCurso',
        title: 'Tipo',
        sortingBy: 'tipoCurso',
        enableSorting: true),
  ]);

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(field: 'nome', operator: 'like', label: 'Nome'),
    DatatableSearchField(field: 'tipoCurso', operator: 'like', label: 'Tipo'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  final _onSelectStreamController = StreamController<Curso>();

  @Output('onSelect')
  Stream<Curso> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Curso selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(
          RoutePaths.formCurso.toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _cursoService.all(filtro);
    } catch (e, s) {
      print('ListaCursoPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<Curso>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnExcluir!, 'Selecione apenas um item!');
      return;
    }

    final isRemove = await SimpleDialogComponent.showConfirm(
        'Tem certeza que deseja escluir: "${selected.map((e) => e.nome).join('-')}", esta operação não pode ser desfeita?');
    if (isRemove) {
      final simpleLoading = SimpleLoading();
      try {
        if (showLoading) {
          simpleLoading.show(target: hostElement);
        }
        await _cursoService.delete(selected.first);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaCursoPage@excluir $e $s');
      } finally {
        if (showLoading) {
          simpleLoading.hide();
        }
      }
    }
  }

  @override
  void onActivate(RouterState? previous, RouterState current) async {
    await load();
  }

  void setInputSearchFocus() {
    datatable?.setInputSearchFocus();
  }

  /// importa cursos de uma planilha
  Future<void> importarXlsx({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      final fileMap = await FrontUtils.getClientFileAsBytes();
      if (fileMap != null) {
        await _cursoService.importXlsx(fileMap['name'], fileMap['bytes']);
      }
    } catch (e, s) {
      print('ListaCursoPage@importarXlsx $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }
}
