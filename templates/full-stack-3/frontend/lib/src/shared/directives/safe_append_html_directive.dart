import 'dart:html' ;

import 'package:ngdart/angular.dart';

@Directive(selector: '[safeAppendHtml]')
class SafeAppendHtmlDirective {
  final Element _element;

  SafeAppendHtmlDirective(this._element);

  @Input()
  set safeAppendHtml(Node? htmlElement) {
    if (htmlElement != null) {
      _element.append(htmlElement);
    }
  }
}
