@JS()
library workarounds;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:js/js.dart';
//import 'package:js/js_util.dart';

//https://github.com/dart-lang/sdk/issues/49626
@JS()
@staticInterop
class JSWindowBase {}

extension E on JSWindowBase {
  // Add any missing members here.
  external Document get document;
  external MediaQueryList matchMedia(String query);
  external print();
}

@JS('document.createTextNode')
@anonymous
external Element createTextNode(dynamic text);

@JS('writeHtmlToIframe')
external void writeHtmlToIframe(IFrameElement el, String? content);

extension IFrameElementExtensions on IFrameElement {
  Future<void> writeHtml(String? content) {
    var completer = Completer();
    // var openF = JsObject.fromBrowserObject(this)['contentWindow']['document']
    //     ['open'] as JsFunction;
    // var writeF = JsObject.fromBrowserObject(this)['contentWindow']['document']
    //     ['write'] as JsFunction;
    // var closeF = JsObject.fromBrowserObject(this)['contentWindow']['document']
    //     ['close'] as JsFunction;
    // //openF.apply([]);
    // writeF.apply([content]);
    // //closeF.apply([]);
    writeHtmlToIframe(this, content);

    this.onLoad.listen((event) { 
      completer.complete();
    });

    return completer.future;
  }
  /// chamar a impressora
  void print() {
    var printPage = JsObject.fromBrowserObject(this)['contentWindow']['print']
        as JsFunction;
    printPage.apply(<dynamic>[]);
  }
}
