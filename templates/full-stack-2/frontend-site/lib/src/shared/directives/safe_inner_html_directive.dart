import 'dart:html' show Element, NodeTreeSanitizer;

import 'package:ngdart/angular.dart';

@Directive(selector: '[safeInnerHtml]')
class SafeInnerHtmlDirective {
  final Element _element;

  SafeInnerHtmlDirective(this._element);

  @Input()
  set safeInnerHtml(safeInnerHtml) {
    // ignore: unsafe_html
    _element.setInnerHtml(safeInnerHtml,
        treeSanitizer: NodeTreeSanitizer.trusted);
  }
}
