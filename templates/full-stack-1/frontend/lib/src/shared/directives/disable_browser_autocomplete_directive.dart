import 'dart:async';
import 'dart:html';
import 'package:ngdart/angular.dart';
import 'dart:html' as html;

///
/// Alterates autocomplete="off" atribute on chrome because it's ignoring it in case of credentials, address or credit card data type.
///
@Directive(selector: '[autocomplete]')
class DisableBrowserAutocompleteDirective implements AfterViewChecked, OnInit {
  bool _chrome = html.window.navigator.userAgent.indexOf('Chrome') > -1;

  final Element _el;

  DisableBrowserAutocompleteDirective(this._el) {
    run();
  }

  @override
  void ngOnInit() {}

  void setTimeout(void Function() callback, [int timeInMilliSec = 0]) {
    Duration timeDelay = Duration(milliseconds: timeInMilliSec);
    Timer(timeDelay, callback);
  }

  @override
  void ngAfterViewChecked() {}

  void run() {
    if (this._chrome) {
      var name = _el.attributes['name'] ?? 'name';
   
      // if (this._el.getAttribute('autocomplete') == 'off') {
      //   setTimeout(() {
             _el.setAttribute('autocomplete', 'new-$name');
      //   });
      // }
    }
  }
}
