@JS()
library bootstrap_interop;

import 'dart:html';
import 'package:js/js.dart';

@JS('bootstrap.Collapse')
class Collapse {
  external Collapse(Element? element, [config]);
  external show();
  external hide();
}

@JS('bootstrap.Dropdown')
class Dropdown {
  external Dropdown(Element? element);
  external show();
  external hide();
}

@JS('console.log')
external consoleLog(dynamic val,[dynamic val2,dynamic val3]);

//external void Dropdown(Element element);
// let toggleBtn = document.getElementsByClassName('.dropdown-toggle')
// let dropdownEl= new bootstrap.Dropdown(toggleBtn);
//  dropdownEl.show();