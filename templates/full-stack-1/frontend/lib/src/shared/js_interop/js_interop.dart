@JS()
library js_interop;

import 'package:js/js.dart';

// Calls invoke JavaScript `JSON.stringify(obj)`.
// @JS('JSON.stringify')
// external String stringify(Object obj);

@JS('console.log')
external void consoleLog(dynamic val);

@JS('limitlessInitCore')
external void limitlessInitCore();

@JS('limitlessInitAfterLoad')
external void limitlessInitAfterLoad();

@JS('pasteHtmlAtCaret')
external void pasteHtmlAtCaret(String html);

@JS('printIframe')
external void printIframe(String cssSelector);

@JS('iframeAfterPrint')
external void iframeAfterPrint(String cssSelector, Function callback);

// funções definidas em index.html
 // usado em workarounds.dart
    // function writeHtmlToIframe(iframeElement, textHtml) {
    //   iframeElement.src = "about:blank";
    //   // Set the iframe's new HTML
    //   iframeElement.contentWindow.document.open();
    //   iframeElement.contentWindow.document.write(textHtml);
    //   iframeElement.contentWindow.document.close();
    // }
    // // usado em workarounds.dart
    // function replaceIframeContent(iframeElement, textHtml) {
    //   iframeElement.src = "about:blank";
    //   iframeElement.contentWindow.document.open();
    //   iframeElement.contentWindow.document.write(textHtml);
    //   iframeElement.contentWindow.document.close();
    // }
    // // usado em js_interop.dart
    // function pasteHtmlAtCaret(html) {
    //   let sel, range;
    //   if (window.getSelection) {
    //     // IE9 and non-IE
    //     sel = window.getSelection();
    //     if (sel.getRangeAt && sel.rangeCount) {
    //       range = sel.getRangeAt(0);
    //       range.deleteContents();

    //       // Range.createContextualFragment() would be useful here but is
    //       // non-standard and not supported in all browsers (IE9, for one)
    //       const el = document.createElement("div");
    //       el.innerHTML = html;
    //       let frag = document.createDocumentFragment(),
    //         node,
    //         lastNode;
    //       while ((node = el.firstChild)) {
    //         lastNode = frag.appendChild(node);
    //       }
    //       range.insertNode(frag);

    //       // Preserve the selection
    //       if (lastNode) {
    //         range = range.cloneRange();
    //         range.setStartAfter(lastNode);
    //         range.collapse(true);
    //         sel.removeAllRanges();
    //         sel.addRange(range);
    //       }
    //     }
    //   } else if (document.selection && document.selection.type != "Control") {
    //     // IE < 9
    //     document.selection.createRange().pasteHTML(html);
    //   }
    // }
    // // usado em js_interop.dart
    // function printIframe(cssSelector) {
    //   var iframe = document.querySelector(cssSelector);
    //   iframe.focus();
    //   iframe.contentWindow.print();
    // }
    // // usado em js_interop.dart
    // function iframeAfterPrint(cssSelector, callback) {
    //   var iframe = document.querySelector(cssSelector);
    //   iframe.contentWindow.addEventListener('afterprint', function (event) {
    //     //print('js afterprint');
    //     callback(event);
    //   });
    // }


