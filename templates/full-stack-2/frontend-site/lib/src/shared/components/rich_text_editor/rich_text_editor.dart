import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import '../modal_component/modal_component.dart';
import '../../directives/safe_inner_html_directive.dart';
import '../../extensions/selection_api_extension.dart';

class HiperLinkModel {
  String url;
  String displayText;
  String target;
  String title;
  HiperLinkModel({
    required this.url,
    required this.displayText,
    this.target = '_blank',
    this.title = '',
  });
}

@Component(
  selector: 'rich-text-editor',
  templateUrl: 'rich_text_editor.html',
  styleUrls: [
    'rich_text_editor.css',
    'e_icons.css',
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
class RichTextEditorComponent implements ControlValueAccessor<String> {
  RichTextEditorComponent();

  HiperLinkModel linkToInsert = HiperLinkModel(displayText: '', url: '');

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

  void clearAllText(e) {
    e.preventDefault();
    textEditContainer?.innerHtml = '';
    _updateModel();
  }

  void changeFontFace(String fontFace) {
    html.document.execCommand('fontName', false, fontFace);
    textEditContainer?.focus();
    _updateModel();
  }

  void changeFontSize(String size) {
    html.document.execCommand('fontSize', false, size);
    textEditContainer?.focus();
    _updateModel();
  }

  void changeFontColor(String color) {
    if (currentAnchorOffset == currentFocusOffset) {
      textEditContainer?.focus();
      html.document.execCommand('foreColor', false, color);
      textEditContainer?.focus();
      return;
    }

    textEditContainer?.focus();
    var selection = html.window.getSelection();
    if (selection != null && currentAnchorNode != null) {
      var expandedSelRange = selection.getRangeAt(0).cloneRange();
      expandedSelRange.collapse(false);
      expandedSelRange.setStart(currentAnchorNode!, currentAnchorOffset);
      expandedSelRange.setEnd(currentAnchorNode!, currentFocusOffset);

      expandedSelRange.deleteContents();
      var span = html.SpanElement();
      //<font color="#cf2626">dfgdfgdfg</font>
      // ignore: unsafe_html
      span.setInnerHtml(
        '<font color="$color">$currentSelectionText</font>',
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
      var frag = html.document.createDocumentFragment();
      //html.Node? node;
      //html.Node? lastNode;
      //while ((node = span.firstChild) != null) {
      //  lastNode = frag.append(node!);
      //}
      expandedSelRange.insertNode(frag);
      _updateModel();
    }
  }

  void changeBackColor(String color) {
    if (currentAnchorOffset == currentFocusOffset) {
      textEditContainer?.focus();
      html.document.execCommand('backColor', false, color);
      textEditContainer?.focus();
      return;
    }

    textEditContainer?.focus();
    var selection = html.window.getSelection();
    if (selection != null && currentAnchorNode != null) {
      var expandedSelRange = selection.getRangeAt(0).cloneRange();
      expandedSelRange.collapse(false);
      expandedSelRange.setStart(currentAnchorNode!, currentAnchorOffset);
      expandedSelRange.setEnd(currentAnchorNode!, currentFocusOffset);

      expandedSelRange.deleteContents();
      var span = html.SpanElement();
      // ignore: unsafe_html
      span.setInnerHtml(
        '<span style="background-color: $color;">$currentSelectionText</span>',
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
      var frag = html.document.createDocumentFragment();
      // html.Node node;
      // html.Node lastNode;
      //while ((node = span.firstChild) != null) {
      //  lastNode = frag.append(node);
      //}
      expandedSelRange.insertNode(frag);
      _updateModel();
    }
  }

  void execCommand(e, String command, [String value = '', bool focus = false]) {
    e.preventDefault();
    html.document.execCommand(command, false, value);
    if (focus == true) {
      textEditContainer?.focus();
    }
  }

  /// caret current-cursor-position start
  int currentAnchorOffset = 0;

  /// end of selection
  int currentFocusOffset = 0;
  html.Node? currentAnchorNode;
  String currentSelectionText = '';

  /// get current  Current Cursor Position of Div textEditContainer
  void saveCurrentCursorPosition([bool setFocus = true]) {
    if (setFocus) {
      textEditContainer?.focus();
    }
    final selection = html.window.getSelection();
    if (selection != null) {
      currentAnchorNode = selection.anchorNode;
      currentAnchorOffset = selection.anchorOffset!;
      currentFocusOffset = selection.focusOffset!;
      currentSelectionText = selection.asString();
    }
    //print('saveCurrentCursorPosition currentAnchorNode $currentAnchorNode');
    //print('saveCurrentCursorPosition currentAnchorOffset $currentAnchorOffset');
    //print('saveCurrentCursorPosition currentFocusOffset $currentFocusOffset');
  }

  void preInsertLink() {
    saveCurrentCursorPosition(true);
    modalLink?.open();
  }

  void _insertHtmlOnSelectionPoint(int point, String htmlString) {
    //print('insertLink currentAnchorOffset $currentAnchorOffset');
    textEditContainer?.focus();
    var selection = html.window.getSelection();
    if (selection != null && currentAnchorNode != null) {
      var expandedSelRange = selection.getRangeAt(0).cloneRange();

      expandedSelRange.collapse(false);
      expandedSelRange.setStart(currentAnchorNode!, point);
      //range.setEnd(currentAnchorNode, currentAnchorOffset);
      var el = html.DivElement();
      // ignore: unsafe_html
      el.setInnerHtml(htmlString,
          treeSanitizer: html.NodeTreeSanitizer.trusted);
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
  }

  void insertLink() {
    //createLink
    //insertHTML
    var link =
        ' <a href="${linkToInsert.url}" target="${linkToInsert.target}" title="${linkToInsert.title}">${linkToInsert.displayText}</a> ';
    _insertHtmlOnSelectionPoint(currentAnchorOffset, link);
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

  void handleUserChangingText(e) {
    //value = textEditContainer.innerHtml;
    _updateModel();
  }

  /// update NG-Model
  void _updateModel() {
    if (textEditContainer != null) {
      _changeController.add(textEditContainer!.innerHtml!);
    }
  }

  //---------------------------- PART NG_MODEL --------------------------------------/

  final _changeController = StreamController<String>();

  @Output()
  Stream<String> get onChange => _changeController.stream;

  @override
  void writeValue(String newVal) {
    value = newVal;
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
