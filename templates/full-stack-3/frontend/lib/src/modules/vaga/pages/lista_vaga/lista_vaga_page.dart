import 'dart:async';
import 'dart:html' as html;

import 'package:sibem_frontend/sibem_frontend.dart';

/// Listagem de vagas
@Component(
  selector: 'lista-vaga-page',
  templateUrl: 'lista_vaga_page.html',
  styleUrls: ['lista_vaga_page.css'],
  directives: [
    coreDirectives,
    customFormDirectives,
    DatatableComponent,
    CustomModalComponent,
  ],
)
class ListaVagaPage implements OnActivate {
  final NotificationComponentService notificationComponentService;
  final VagaService _vagaService;

  final Router _router;

  @Input('insideModal')
  bool insideModal = false;

  @Input('filtroBloqueioEncaminhamento')
  set filtroBloqueioEncaminhamento(bool val) {
    filtro.bloqueioEncaminhamento = val;
  }

  @ViewChild('datatable')
  DatatableComponent? datatable;

  @ViewChild('modalBloquearVaga')
  CustomModalComponent? modalBloquearVaga;

  @ViewChild('modalDesbloquearVaga')
  CustomModalComponent? modalDesbloquearVaga;

  @ViewChild('btnExcluir')
  html.Element? btnExcluir;

  @ViewChild('btnBloquearVaga')
  html.Element? btnBloquearVaga;

  @ViewChild('btnDesbloquearVaga')
  html.Element? btnDesbloquearVaga;

  @ViewChild('modalListaBloqueios')
  CustomModalComponent? modalListaBloqueios;

  @ViewChild('dtBloqueios')
  DatatableComponent? dtBloqueios;

  final html.Element hostElement;
  var itemSelected = Vaga.invalid();
  var bloqueioEncaminhamento = BloqueioEncaminhamento.invalid();

  final filtro = Filters(limit: 12, offset: 0);

  late DatatableSettings dtSettings;

  ListaVagaPage(this.notificationComponentService, this.hostElement,
      this._vagaService, this._router) {
    dtSettings = DatatableSettings(colsDefinitions: [
      DatatableCol(
          key: 'id',
          title: 'Id',
          sortingBy: 'id',
          enableSorting: true,
          visibility: false),
      DatatableCol(
          key: 'isFromWeb', title: 'WEB', format: DatatableFormat.bool),
      DatatableCol(
          key: Vaga.validadoCol,
          title: 'Validado',
          visibility: true,
          format: DatatableFormat.bool,
          sortingBy: Vaga.bloqueioEncaminhamentoCol,
          enableSorting: true,
          customRenderHtml: (map, instance) {
            final vag = (instance as Vaga);
            final div = html.DivElement();
            if (vag.validado == false) {
              final btn = html.ButtonElement()
                ..type = 'button'
                ..title = 'Validar'
                ..classes.addAll([
                  'btn',
                  'btn-flat-success',
                  'border-width-2', 'btn-sm',                 
                ])              
                ..innerHtml = 'Validar'
                ..onClick.listen((event) async {
                  // interrompe o evento rowClick do DataTable
                  event.stopPropagation();
                  final isValidar = await SimpleDialogComponent.showConfirm(
                      'Tem certeza que deseja validar esta vaga de ${vag.cargoNome} id ${vag.id}, esta operação não pode ser desfeita');
                  if (isValidar) {
                    validarVaga(vag);
                  }
                });
              div.append(btn);
            } else {
              final span = html.SpanElement();
              span.text = 'Sim';
              div.append(span);
            }
            return div;
          }),
      DatatableCol(
          key: 'cargoNome',
          title: 'Cargo',
          enableSorting: true,
          sortingBy: 'cargos.nome'),
      DatatableCol(
        key: 'idadeMinima',
        title: 'Idade Minima',
        visibility: false,
      ),
      DatatableCol(
        key: 'idadeMaxima',
        title: 'Idade Maxima',
        visibility: false,
      ),
      DatatableCol(
          key: 'exigeExperiencia',
          title: 'Exige experiência',
          visibility: false,
          format: DatatableFormat.bool),
      DatatableCol(
          key: 'aceitaExperienciaMei',
          title: 'Aceita Experiência MEI',
          visibility: false,
          format: DatatableFormat.bool),

      DatatableCol(
          key: 'experienciaInformal',
          title: 'Aceita Experiência Informal',
          visibility: false,
          format: DatatableFormat.bool),
      DatatableCol(
          key: 'tempoMinimoExperiencia',
          title: 'Tempo Minimo Experiência',
          visibility: false),
      DatatableCol(
          key: 'tempoMaximoExperiencia',
          title: 'Tempo Maximo Experiência',
          visibility: false),
      DatatableCol(
          key: 'empregadorNome',
          title: 'Empregador',
          enableSorting: true,
          sortingBy: 'pessoas.nome'),
      DatatableCol(
        key: 'empregadorContato',
        title: 'Contato Empregador',
        visibility: false,
      ),
      DatatableCol(
          key: 'contatoEncaminhamento',
          title: 'Contato Encaminhamento',
          visibility: false),
      DatatableCol(
          key: 'grauEscolaridade',
          title: 'Escolaridade',
          visibility: true,
          enableSorting: true,
          sortingBy: 'escolaridades.ordemGraduacao'),
      DatatableCol(
          key: 'ordemGraduacao', title: 'Ordem graduação', visibility: false),
      DatatableCol(
          key: 'dataAbertura',
          title: 'Abertura',
          format: DatatableFormat.date,
          sortingBy: 'dataAbertura',
          enableSorting: true),
      DatatableCol(
          key: 'dataEncerramento',
          title: 'Encerramento',
          format: DatatableFormat.date),
      DatatableCol(
          key: 'cargaHorariaSemanal',
          title: 'Carga Horária Semanal',
          visibility: false),

      DatatableCol(
          key: 'numeroVagas',
          title: 'Vagas',
          visibility: true,
          sortingBy: 'numeroVagas',
          enableSorting: true),
      //Total encaminhados
      DatatableCol(
          key: Vaga.quantidadeEncaminhadaCol,
          title: 'Encaminhados',
          visibility: true,
          sortingBy: Vaga.quantidadeEncaminhadaCol,
          enableSorting: true),
      DatatableCol(
          key: Vaga.numeroEncaminhamentosCol,
          title: 'Limite Encaminha.',
          visibility: true),

      DatatableCol(
          key: Vaga.aceitaFumanteCol,
          title: 'Aceita Fumante',
          visibility: false,
          format: DatatableFormat.bool),
      DatatableCol(key: 'tipoVaga', title: 'Tipo Vaga', visibility: false),
      DatatableCol(key: 'turno', title: 'Turno', visibility: false),
      DatatableCol(
          key: Vaga.bloqueioEncaminhamentoCol,
          title: 'Bloqueio',
          visibility: true,
          format: DatatableFormat.bool,
          sortingBy: Vaga.bloqueioEncaminhamentoCol,
          enableSorting: true,
          customRenderHtml: (map, instance) {
            final value = map[Vaga.bloqueioEncaminhamentoCol];
            final span = html.SpanElement();
            if (value == true) {
              span.classes.addAll(
                ['badge', 'bg-danger', 'bg-opacity-10', 'text-danger'],
              );
              span.text = 'Sim';
            } else {
              span.classes.addAll(
                ['badge', 'bg-success', 'bg-opacity-10', 'text-success'],
              );
              span.text = 'Não';
            }
            return span;
          }),

      DatatableCol(
          key: 'id',
          title: '',
          visibility: true,
          customRenderHtml: (map, instance) {
            final div = html.DivElement();

            final btn = html.ButtonElement()
              ..type = 'button'
              ..title = 'Consultar Histórico de bloqueios'
              ..classes.addAll(
                  ['btn', 'btn-flat-primary', 'border-transparent', 'btn-icon'])
              //..text = 'Consultar'
              ..innerHtml = '<i class="ph-file-lock"></i>'
              ..onClick.listen((event) {
                // interrompe o evento rowClick do DataTable
                event.stopPropagation();
                itemSelected = instance as Vaga;
                // print('itemSelected idVaga ${itemSelected.id} ');
                modalListaBloqueios?.open();
                loadBloqueiosEncaminhamento();
              });
            div.append(btn);
            return div;
          }),
    ]);
  }

  /// lista de vagas
  DataFrame<Vaga> items = DataFrame<Vaga>.newClear();

  DataFrame<BloqueioEncaminhamento> bloqueiosEncaminhamento =
      DataFrame<BloqueioEncaminhamento>.newClear();

  List<DatatableSearchField> sInFields = <DatatableSearchField>[
    DatatableSearchField(
        field: 'pessoas.nome', operator: 'like', label: 'Nome Empregador'),
    DatatableSearchField(
        field: 'cargos.nome', operator: 'like', label: 'Nome Cargo'),
    DatatableSearchField(
        field: 'escolaridades.nome',
        operator: 'like',
        label: 'Nome Escolaridade'),
    DatatableSearchField(field: 'id', operator: '=', label: 'Id'),
  ];

  void onDtRequestData(e) {
    load();
  }

  DatatableSettings dtSettingsBloqueios = DatatableSettings(colsDefinitions: [
    DatatableCol(key: 'id', title: 'Id', visibility: false),
    DatatableCol(key: BloqueioEncaminhamento.acaoCol, title: 'Tipo'),
    DatatableCol(
        key: BloqueioEncaminhamento.justificativaCol, title: 'Justificativa'),
    DatatableCol(
        key: BloqueioEncaminhamento.dataCol,
        title: 'Data',
        format: DatatableFormat.dateTime),
    DatatableCol(key: 'usuarioResponsavel', title: 'Responsavel'),
  ]);

  void onDtBloqueiosRequestData(e) {
    loadBloqueiosEncaminhamento();
  }

  final _onSelectStreamController = StreamController<Vaga>();

  @Output('onSelect')
  Stream<Vaga> get onSelect => _onSelectStreamController.stream;

  void onSelectItem(Vaga selected) async {
    itemSelected = selected;
    if (insideModal) {
      _onSelectStreamController.add(selected);
    } else {
      _router.navigate(
          RoutePaths.formVaga.toUrl(parameters: {'id': '${selected.id}'}));
    }
  }

  Future<void> load({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: hostElement);
      }
      items = await _vagaService.all(filtro);
    } catch (e, s) {
      print('ListaVagaPage@load $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  /// lista todos os bloqueios de encaminhamento de uma vaga
  Future<void> loadBloqueiosEncaminhamento({bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show(target: dtBloqueios?.rootElement);
      }
      bloqueiosEncaminhamento =
          await _vagaService.getAllBloqueiosEncaminhamento(itemSelected.id);
    } catch (e, s) {
      print('ListaVagaPage@loadBloqueiosEncaminhamento $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> validarVaga(Vaga vaga, {bool showLoading = true}) async {
    final simpleLoading = SimpleLoading();
    try {
      if (showLoading) {
        simpleLoading.show();
      }
      await _vagaService.validarVaga(vaga);
      await load(showLoading: false);
    } catch (e, s) {
      print('ListaVagaPage@validarVaga $e $s');
    } finally {
      if (showLoading) {
        simpleLoading.hide();
      }
    }
  }

  Future<void> excluir({bool showLoading = true}) async {
    final selected = datatable!.getAllSelected<Vaga>();
    if (selected.isEmpty || selected.length > 1) {
      PopoverComponent.showPopover(btnExcluir!, 'Selecione apenas um item!');
      return;
    }

    final isRemove = await SimpleDialogComponent.showConfirm(
        'Tem certeza que deseja escluir: "${selected.map((e) => e.cargoNome).join('-')}", esta operação não pode ser desfeita?');
    if (isRemove) {
      final simpleLoading = SimpleLoading();
      try {
        if (showLoading) {
          simpleLoading.show(target: hostElement);
        }
        await _vagaService.deleteAll(selected);
        await load(showLoading: false);
      } catch (e, s) {
        print('ListaVagaPage@excluir $e $s');
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

  void irParaNewVaga() {
    _router.navigate(RoutePaths.formVaga.toUrl(parameters: {'id': 'new'}));
  }

  void openBloquearVaga() {
    final vagasSelected = datatable!.getAllSelected<Vaga>();
    if (vagasSelected.isEmpty || vagasSelected.length > 1) {
      PopoverComponent.showPopover(
          btnBloquearVaga!, 'Selecione apenas um item!');
      return;
    }
    final selVaga = vagasSelected.first;

    if (selVaga.bloqueioEncaminhamento) {
      PopoverComponent.showPopover(btnBloquearVaga!, 'Vaga já bloqueada');
      return;
    }

    modalBloquearVaga?.open();

    bloqueioEncaminhamento = BloqueioEncaminhamento(
      idVaga: selVaga.id,
      data: DateTime.now(),
      justificativa: '',
      acao: TipoBloqueioEncaminhamento.bloqueioTemporario,
      idUsuarioResponsavel: -1,
    );
  }

  void openDesbloquearVaga() {
    final vagasSelected = datatable!.getAllSelected<Vaga>();
    if (vagasSelected.isEmpty || vagasSelected.length > 1) {
      PopoverComponent.showPopover(
          btnDesbloquearVaga!, 'Selecione apenas um item!');
      return;
    }
    final selVaga = vagasSelected.first;

    if (selVaga.bloqueioEncaminhamento == false) {
      PopoverComponent.showPopover(btnDesbloquearVaga!, 'Vaga já desbloqueada');
      return;
    }

    if (selVaga.dataEncerramento != null) {
      final now = DateTime.now();
      if (now.isAfter(selVaga.dataEncerramento!)) {
        PopoverComponent.showPopover(
            btnDesbloquearVaga!, 'Alterar a data de encerramento antes!');
      }
      return;
    }

    modalDesbloquearVaga?.open();

    bloqueioEncaminhamento = BloqueioEncaminhamento(
      idVaga: selVaga.id,
      data: DateTime.now(),
      justificativa: '',
      acao: TipoBloqueioEncaminhamento.desbloqueio,
      idUsuarioResponsavel: -1,
    );
  }

  void bloquearVaga() async {
    if (bloqueioEncaminhamento.justificativa.trim().length < 3) {
      SimpleDialogComponent.showAlert(
          'A justificativa deve ter mais de 3 caracteres!');
      return;
    }
    final simpleLoading = SimpleLoading();
    try {
      modalBloquearVaga?.close();
      simpleLoading.show();
      await _vagaService.bloquearVaga(bloqueioEncaminhamento);

      load(showLoading: false);
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Não foi possivel bloquear esta vaga',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }

  void desbloquearVaga() async {
    if (bloqueioEncaminhamento.justificativa.trim().length < 3) {
      SimpleDialogComponent.showAlert(
          'A justificativa deve ter mais de 3 caracteres!');
      return;
    }
    final simpleLoading = SimpleLoading();
    try {
      modalDesbloquearVaga?.close();
      await _vagaService.desbloquearVaga(bloqueioEncaminhamento);

      load(showLoading: false);
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Não foi possivel desbloquear esta vaga',
          subMessage: '$e $s');
    } finally {
      simpleLoading.hide();
    }
  }
}
