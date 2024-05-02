import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'package:new_sali_frontend/src/shared/extensions/selection_api_extension.dart';

import '../../directives/safe_inner_html_directive.dart';

class HiperLinkModel {
  String url;
  String displayText;
  String target;
  String title;
  HiperLinkModel({
    this.url = '',
    this.displayText = '',
    this.target = '',
    this.title = '',
  });
}

@Component(
  selector: 'rich-text-editor',
  templateUrl: 'rich_text_editor.html',
  styleUrls: [
    'rich_text_editor.css',
    // 'e_icons.css',
  ],
  directives: [
    coreDirectives,
    formDirectives,
    CustomModalComponent,
    SafeInnerHtmlDirective,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, RichTextEditorComponent),
  ],
)

///
class RichTextEditorComponent
    implements ControlValueAccessor<String>, OnInit, AfterViewInit {
  RichTextEditorComponent() {
    generateColors();
  }

  @override
  void ngOnInit() {
    html.document.addEventListener('selectionchange', (e) {
      if (html.document.activeElement == textEditContainer) {
        saveSelection();
      }
    });
  }

  @override
  void ngAfterViewInit() {}

  HiperLinkModel linkToInsert = HiperLinkModel();

  @ViewChild('textEditContainer')
  html.DivElement? textEditContainer;

  @ViewChild('modalLink')
  CustomModalComponent? modalLink;

  void textFormat(e, String command) {
    e.preventDefault();
    //document.execCommand(command, defaultUi, value);
    html.document.execCommand(command, false, null);
    // textEditContainer.focus();
    _updateModel();
  }

  void changeToTag(event, String? value) {
    execCommand(event, 'formatBlock', value, true);
    _updateModel();
  }

  void copiarSemFormatacao() {
    final text = textEditContainer?.innerText ?? '';
    FrontUtils.copyToClipboard(text);
  }

  void copiarComFormatacao() {
    final text = textEditContainer?.innerHtml ?? '';
    FrontUtils.copyToClipboard(text);
  }

  void colarComFormatacao() async {
    final text = await FrontUtils.getClipboardText();
    textEditContainer?.setInnerHtml(text,
        treeSanitizer: html.NodeTreeSanitizer.trusted);
    _updateModel();
  }

  void colarSemFormatacao() async {
    final htmlStr = await FrontUtils.getClipboardText();
    final text = FrontUtils.stripTags(htmlStr);
    textEditContainer?.innerText = text;
    _updateModel();
  }

  void limparTodaFormatacao() {
    final htmlStr = textEditContainer?.innerHtml ?? '';
    final text = FrontUtils.stripTags(htmlStr);
    textEditContainer?.innerText = text;
    _updateModel();
  }

  void removeAllLineBreaks() {
    final htmlStr = textEditContainer?.innerHtml ?? '';
    final text = htmlStr.replaceAll('<br>', '');
    textEditContainer?.setInnerHtml(text,
        treeSanitizer: html.NodeTreeSanitizer.trusted);
    _updateModel();
  }

  //void removeBackColor() {}

  void clearAllText(e) {
    e.preventDefault();
    textEditContainer?.innerHtml = '';
    _updateModel();
  }

  void removeInvalidCharacters() {
    final htmlStr = textEditContainer?.innerHtml ?? '';
    final text = SaliCoreUtils.removeNonIso88591Characters(htmlStr);
    textEditContainer?.setInnerHtml(text,
        treeSanitizer: html.NodeTreeSanitizer.trusted);
    _updateModel();
  }

  void changeFontFace(String? fontFace) {
    html.document.execCommand('fontName', false, fontFace);
    textEditContainer?.focus();
    _updateModel();
  }

  void changeFontSize(String? size) {
    html.document.execCommand('fontSize', false, size);
    textEditContainer?.focus();
    _updateModel();
  }

  // void changeFontColor(String? color) {
  //   print('changeFontColor $color');
  //   html.document.execCommand('foreColor', false, color);
  //   _updateModel();
  // }

  int? currentBaseOffset;
  int? currentExtentOffset;
  html.Node? currentFocusNode;

  /// caret current-cursor-position start
  int? currentAnchorOffset;

  /// end of selection
  int? currentFocusOffset;
  html.Node? currentAnchorNode;
  String? currentSelectionText;

  void saveSelection() {
    // textEditContainer.sel
    final selection = html.window.getSelection();
    if (selection != null) {
      currentBaseOffset = selection.baseOffset;
      currentExtentOffset = selection.extentOffset;
      currentFocusNode = selection.focusNode;
      currentAnchorNode = selection.anchorNode;
      currentAnchorOffset = selection.anchorOffset;
      currentFocusOffset = selection.focusOffset;
      currentSelectionText = selection.asString();
    } else {
      currentBaseOffset = null;
      currentExtentOffset = null;
      currentFocusNode = null;
      currentAnchorNode = null;
      currentAnchorOffset = null;
      currentFocusOffset = null;
      currentSelectionText = null;
    }
  }

  String backColor = '#fff';
  String fontColor = '#000';

  void changeFontColor(String color) {
    fontColor = color;
    applyFontColor();
  }

  void applyFontColor() {
    if (currentSelectionText != null &&
        currentSelectionText?.isNotEmpty == true) {
      FrontUtils.pasteHtmlAtCaret(
          '<span style="color: $fontColor;">$currentSelectionText</span>');
    }
    // else {
    //   html.document.execCommand('foreColor', false, backColor);
    // }
    _updateModel();
  }

  void changeBackColor(String color) {
    backColor = color;
    applyBackColor();
  }

  void applyBackColor() {
    if (currentSelectionText != null &&
        currentSelectionText?.isNotEmpty == true) {
      FrontUtils.pasteHtmlAtCaret(
          '<span style="background-color: $backColor;">$currentSelectionText</span>');
    }
    // else {
    //   html.document.execCommand('backColor', false, backColor);
    // }
    _updateModel();
  }

  List<String> cores = [
    'white',
    'black',
    'red',
    'yellow',
    'blue',
    'green',
    'orange'
  ];
  void generateColors() {
    var maxPaletteBoxes = 7 * 6;
    for (var i = 0; i < maxPaletteBoxes; i++) {
      // generating a random hex color code
      var randomHexInt =
          (Random().nextDouble() * 0xffffff).floor().toRadixString(16);
      var randomHex = '#${randomHexInt.padLeft(6, "0")}';
      cores.add(randomHex);
    }
  }

  void execCommand(e, String command, [String? value, bool focus = false]) {
    e.preventDefault();
    html.document.execCommand(command, false, value);
    if (focus == true) {
      textEditContainer?.focus();
    }
  }

  void preInsertLink() {
    // saveCurrentCursorPosition(true);
    modalLink?.open();
  }

  void _insertHtmlOnSelectionPoint(int point, String htmlString) {
    //print('insertLink currentAnchorOffset $currentAnchorOffset');
    textEditContainer?.focus();
    var selection = html.window.getSelection();
    var expandedSelRange = selection!.getRangeAt(0).cloneRange();

    expandedSelRange.collapse(false);

    expandedSelRange.setStart(currentAnchorNode!, point);
    //range.setEnd(currentAnchorNode, currentAnchorOffset);
    var el = html.DivElement();
    // ignore: unsafe_html
    el.setInnerHtml(htmlString, treeSanitizer: html.NodeTreeSanitizer.trusted);
    var frag = html.document.createDocumentFragment();
    html.Node? node;
    html.Node? lastNode;
    while ((node = el.firstChild) != null) {
      lastNode = frag.append(node!);
    }
    expandedSelRange.insertNode(frag);

    // Preserve the selection
    if (lastNode != null) {
      expandedSelRange.setEndAfter(lastNode);
      selection.removeAllRanges();
      selection.addRange(expandedSelRange);
    }
  }

  void insertLink() {
    //createLink
    //insertHTML
    final link =
        ' <a href="${linkToInsert.url}" target="${linkToInsert.target}" title="${linkToInsert.title}">${linkToInsert.displayText}</a> ';
    _insertHtmlOnSelectionPoint(currentAnchorOffset!, link);
    //html.document.execCommand('insertHTML', false, link);
    modalLink?.close();
    textEditContainer?.focus();
    _updateModel();
  }

  String _value = '';

  // ignore: unnecessary_getters_setters
  String get value => _value;
  // ignore: unnecessary_getters_setters
  set value(String v) {
    _value = v;
  }

  bool acabouDeColar = false;

  void handleUserChangingText(html.Event e) {
    if (acabouDeColar && textEditContainer?.innerHtml != null) {
      textEditContainer!.innerHtml = SaliCoreUtils.removeNonIso88591Characters(
          textEditContainer!.innerHtml!);
    }
    acabouDeColar = false;
    _updateModel();
  }

  void handleUserPastText(html.ClipboardEvent e) {
    acabouDeColar = true;  
    // if (e.clipboardData != null) {
    //   final types = e.clipboardData!.types ?? [];
    //   print('handleUserPastText types: $types ');
    //   var pastedData = '';
    //   if (types.contains('text/html')) {
    //     pastedData += e.clipboardData!.getData('text/html');
    //   }
    //   if (types.contains('text/rtf')) {
    //     pastedData += e.clipboardData!.getData('text/rtf');
    //   }
    //   if (types.contains('text/plain')) {
    //     pastedData += e.clipboardData!.getData('text/plain');
    //   }
    //   print('handleUserPastText pastedData: $pastedData ');
    // }
  }

  /// update NG-Model
  void _updateModel() {
    _changeController.add(textEditContainer!.innerHtml!);
  }

  //---------------------------- PART NG_MODEL --------------------------------------/

  final _changeController = StreamController<String>();

  @Output()
  Stream<String> get onChange => _changeController.stream;

  @override
  void writeValue(String? newVal) {
    value = newVal ?? '';
  }

  @override
  void registerOnChange(callback) {
    onChange.listen((value) => callback(value));
  }

  @override
  void registerOnTouched(TouchFunction callback) {}

  @override
  void onDisabledChanged(bool state) {}
}
