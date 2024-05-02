import 'dart:async';
import 'dart:html';
import 'package:ngdart/angular.dart';

@Directive(
  selector: '[contenteditableModel]',
  providers: [
    //ExistingProvider(NgControl, NgModel),
  ],
  //exportAs: 'ngForm',
  visibility: Visibility.all,
)
class ContentEditableModelDirective implements AfterChanges, OnInit {
  late StreamController<dynamic> _update;
  late StreamController<dynamic> _onSubmit;
  dynamic _model;
  bool _modelChanged = false;

  @Input('placeholder')
  String placeholder = 'Digite..';

  /// se true aciona evento submit a precionar enter
  @Input('submitOnEnter')
  bool submitOnEnter = true;

  /// se true aciona evento submit a precionar esc
  @Input('submitOnEscape')
  bool submitOnEscape = true;

  /// se true aciona evento submit perder foco
  @Input('submitOnBlur')
  bool submitOnBlur = true;

  /// se tru disabilita a edição no evento de submit
  @Input('disableEditOnSubmit')
  bool disableEditOnSubmit = true;

  @Input('maxlength')
  int maxlength = 100;

  bool _startEditable = true;
  bool _startEditableChanged = false;

  /// se true inicia ja editavel
  @Input('startEditable')
  set startEditable(bool value) {
    if (identical(_startEditable, value)) return;
    _startEditable = value;
    //if (identical(value, viewModel)) return;
    _startEditableChanged = true;
  }

  @Input('enableEditOnClick')
  bool enableEditOnClick = true;

  @Input('contenteditableModel')
  set model(dynamic value) {
    //print('ContentEditableModelDirective@set model value: $value');

    /// Make sure input actually changed so we don't override
    /// viewModel passed to us using viewToModelUpdate from proxies.
    if (identical(_model, value)) return;
    _model = value;
    if (identical(value, viewModel)) return;

    /// Mark as changed so we can commit to viewModel in ngAfterChanges
    /// lifecycle.
    _modelChanged = true;
  }

  //String lastViewModel = '';
  dynamic viewModel;

  final Element nativeElement;

  ContentEditableModelDirective(this.nativeElement) {
    _init();
  }

  //
  // bool get disabled => super.disabled!;
  // @Input('ngDisabled')
  // set disabled(bool isDisabled) {
  //   toggleDisabled(isDisabled);
  // }

  // This function prevents constructor inlining for smaller code size since
  void _init() {
    _update = StreamController.broadcast(sync: true);
    _onSubmit = StreamController.broadcast(sync: true);
    //print('_init startEditable $startEditable');
    if (_startEditable) {
      enableEdit();
    } else {
      disableEdit();
    }
    // ! Please don't remove, the multiple return paths prevent inlining.
  }

  @Output('contenteditableModelChange')
  Stream<dynamic> get update => _update.stream;

  @Output('contenteditableModelSubmit')
  Stream<dynamic> get onSubmit => _onSubmit.stream;

  @override
  void ngAfterChanges() {
    if (_modelChanged) {
      // print('ngAfterChanges ');
      refreshView();
      viewModel = _model;
      _modelChanged = false;
    }
    if (_startEditableChanged) {
      if (_startEditable) {
        enableEdit();
      } else {
        disableEdit();
      }
      _startEditableChanged = false;
    }
  }

  @override
  void ngOnInit() {
    // print('ngOnInit ');
    //_control.updateValueAndValidity(emitEvent: false);
  }

  @HostListener('keyup')
  void onInput(KeyboardEvent e) {
    var newValue = this.nativeElement.innerText;
    this.viewModel = newValue;
    //print('keyup onInput() newValue ${e.key} ${e.keyCode}');
    _update.add(newValue);
  }

  var lastkeyCode = -1;

  @HostListener('keydown')
  void onKeydown(KeyboardEvent e) {
    lastkeyCode = e.keyCode;
    if ((submitOnEnter && e.keyCode == KeyCode.ENTER) ||
        (submitOnEscape && e.keyCode == KeyCode.ESC)) {
      e.preventDefault();
      _submit();
    }

    var keys = [KeyCode.DELETE, KeyCode.NUM_DELETE, KeyCode.BACKSPACE];
    //verifica se o texto esta selecionado
    var selObj = window.getSelection();
    var isTextSel = selObj != null &&
        selObj.anchorNode?.parentNode == nativeElement &&
        selObj.toString() == nativeElement.text;

    if (nativeElement.innerText.length >= maxlength &&
        keys.contains(lastkeyCode) == false &&
        isTextSel == false) {
      e.preventDefault();
    }
  }

  @HostListener('blur')
  void onBlur(e) {
    if (submitOnBlur &&
        [KeyCode.ENTER, KeyCode.ESC].contains(lastkeyCode) == false) {
      //print('onBlur _submit');
      _submit();
    }
  }

  void _submit() {
    //print('_submit');
    if (disableEditOnSubmit) {
      disableEdit();
    }
    _onSubmit.add(_model);
  }

  void refreshView() {
    nativeElement.innerText = this._model;
  }

  @HostListener('click')
  void onClick(e) {
    // if (enableEditOnClick) {
    //   enableEdit();
    // }
  }

  /// abilita edição
  void enableEdit() {
    nativeElement.attributes['contenteditable'] = 'true';
  }

  void disableEdit() {
    nativeElement.attributes.remove('contentEditable');
  }
}
