// ignore_for_file: unsafe_html

import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

//import 'package:money2/money2.dart';

class Utils {
  static String hidePartsOfString(String string, {int visibleCharacters = 2}) {
    return string.substring(0, visibleCharacters) +
        ('*' * (string.length - visibleCharacters));
  }

//unconsore
  static String uncensored(String string, {int consoreLevel = 2}) {
    final parts = string.split('@');

    if (parts.length != 2) {
      // Handle the case where there is no "@" separator in the string
      return string;
    }

    final stringBeforeA = parts[0];
    final stringAfterA = parts[1];

    final unconsoredBeforeA = stringBeforeA.replaceRange(
        consoreLevel,
        stringBeforeA.length - consoreLevel,
        '*' * (stringBeforeA.length - consoreLevel * 2));

    return '$unconsoredBeforeA@$stringAfterA';
  }

  static void downloadFile(Uint8List bytes, String fileName, String type) {
    //= await pdf.save();
    final blob = html.Blob([bytes], type);
    final url = html.Url.createObjectUrlFromBlob(blob);
    //open(url, target, windowFeatures)
    //html.window.open(url, '_blank','Guia de Encaminhamento.pdf');
    var anchor = html.AnchorElement(href: url);
    //anchor.style.display = 'none';
    anchor.download = fileName;
    anchor.click();
    //Url.revokeObjectUrl(url);
  }

  static Future<String> getNetworkTextFile(String url,
      {Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return response.body;
  }

  static void printFileHtml(String content) {
    var blob = html.Blob([], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.document.getElementById('printFrame')?.remove();

    var printFrame = html.IFrameElement();
    printFrame.src = url;
    printFrame.id = 'printFrame';
    html.document.body!.append(printFrame);

    printFrame.style.display = 'none';
    printFrame.onLoad.listen((event) {
      var printPage = js.JsObject.fromBrowserObject(printFrame)['contentWindow']
          ['print'] as js.JsFunction;
      printPage.apply(<dynamic>[]);

      //(printFrame.contentWindow as JSWindowBase).print();

      // var matchMedia =
      //     js.JsObject.fromBrowserObject(printFrame)['contentWindow']
      //         ['matchMedia'] as js.JsFunction;
      //var mediaQueryList = matchMedia.apply(['print']);
      // var mediaAddListener =
      //     js.JsObject.fromBrowserObject(mediaQueryList)['addListener']
      //         as js.JsFunction;
      // mediaAddListener.apply([
      //   js.allowInterop((mql) {
      //     print('print event $mql');
      //   })
      // ]);

      var addEventListener =
          js.JsObject.fromBrowserObject(printFrame)['contentWindow']
              ['addEventListener'] as js.JsFunction;

      addEventListener.apply([
        'afterprint',
        js.allowInterop((mql) {
          print('afterprint event $mql');
          html.document.getElementById('printFrame')?.remove();
        })
      ]);
    });
  }

  /// so funciona com PDF/HTML/TXT/XML
  static void printFileBytes(Uint8List bytes, String type) {
    //var debug = {'hello': "world"};
    //var blob = Blob([jsonEncode(debug)], 'application/json');
    final blob = html.Blob([bytes], type);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.document.getElementById('printFrame')?.remove();

    var printFrame = html.IFrameElement();
    printFrame.src = url;
    printFrame.id = 'printFrame';
    html.document.body!.append(printFrame);

    printFrame.style.display = 'none';
    printFrame.onLoad.listen((event) {
      var printPage = js.JsObject.fromBrowserObject(printFrame)['contentWindow']
          ['print'] as js.JsFunction;
      printPage.apply(<dynamic>[]);

      //(printFrame.contentWindow as JSWindowBase).print();

      // var matchMedia =
      //     js.JsObject.fromBrowserObject(printFrame)['contentWindow']
      //         ['matchMedia'] as js.JsFunction;
      //var mediaQueryList = matchMedia.apply(['print']);
      // var mediaAddListener =
      //     js.JsObject.fromBrowserObject(mediaQueryList)['addListener']
      //         as js.JsFunction;
      // mediaAddListener.apply([
      //   js.allowInterop((mql) {
      //     print('print event $mql');
      //   })
      // ]);

      var addEventListener =
          js.JsObject.fromBrowserObject(printFrame)['contentWindow']
              ['addEventListener'] as js.JsFunction;

      addEventListener.apply([
        'afterprint',
        js.allowInterop((mql) {
          print('afterprint event $mql');
          //document.getElementById('printFrame')?.remove();
        })
      ]);
    });
  }

  static Future<dynamic> fileToDataUrl(html.File file) async {
    final completer = Completer();
    final reader = html.FileReader();
    reader.onLoad.listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as html.FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsDataUrl(file);
    return completer.future;
  }

  static Future<dynamic> fileToArrayBuffer(html.File file) async {
    final completer = Completer();
    final reader = html.FileReader();
    reader.onLoad.listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as html.FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  static Future<dynamic> blobToArrayBuffer(html.Blob blob) async {
    final completer = Completer();
    final reader = html.FileReader();
    reader.onLoad.listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as html.FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  static Future<dynamic> uploadFiles(
    String url,
    List<html.File> files, {
    Map<String, String>? headers,
    dynamic dataToSender,
    String? bodyEncoding = 'utf8',
    Map<String, String>? queryParams,
    bool resizeImage = false,
    bool compressImage = false,
    int maxImageWidth = 1024,
    int maxImageHeight = 768,
  }) async {
    var headersDefault = {
      'Authorization':
          'Bearer ' + html.window.sessionStorage['YWNjZXNzX3Rva2Vu'].toString()
    };

    var requestUrl = Uri.parse(url);
    if (queryParams != null) {
      var queryString = Uri(queryParameters: queryParams).query;
      requestUrl = Uri.parse(url + '?' + queryString);
    }

    var request = http.MultipartRequest('POST', requestUrl);

    if (headers != null) {
      request.headers.addAll(headers);
    } else {
      request.headers.addAll(headersDefault);
    }

    if (dataToSender != null) {
      if (dataToSender is Map<String, dynamic>) {
        if (bodyEncoding == null) {
          request.fields['data'] = jsonEncode(dataToSender);
        } else if (bodyEncoding == 'utf8') {
          request.fields['data'] = jsonEncode(dataToSender);
          //ISO-8859-1
        } else if (bodyEncoding == 'latin1') {
          var latin1Bytes = latin1.encode(jsonEncode(dataToSender));
          request.fields['data'] = latin1Bytes.toString();
        }
      } else {
        request.fields['data'] = dataToSender;
      }
    }

    if (files.isNotEmpty == true) {
      for (var file in files) {
        var fileBytes = await fileToArrayBuffer(file);

        request.files.add(http.MultipartFile.fromBytes('file[]', fileBytes,
            contentType: MediaType('application', 'octet-stream'),
            filename: file.name));
      }
    }

    //fields.forEach((k, v) => request.fields[k] = v);
    var streamedResponse = await request.send();
    var resp = await http.Response.fromStream(streamedResponse);
    //var respJson = jsonDecode(resp.body);

    return resp;
  }

  static String getFormatedCurrency(dynamic valor) {
    if (valor == null) {
      return valor;
    }
    //final sellPrice = Money.from(valor, Currency.create('BRL', 2, symbol: r'R$ '));
    // return sellPrice.toString();
    var formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return formatter.format(valor);
  }

  static String truncateWithEllipsis(String myString,
      {int length = 7, omission = '...'}) {
    return (myString.length <= length)
        ? myString
        : myString.substring(0, length) + omission;
  }

  static String truncate(String text, {length = 7, omission = '...'}) {
    if (length >= text.length) {
      return text;
    }
    return text.replaceRange(length, text.length, omission);
  }

  /// Divida a string em pedaços de tamanho máximo parando na quebra de linha
  /// https://stackoverflow.com/questions/72883396/split-string-into-chunks-of-max-size-stopping-at-line-break
  static List<String> slicesText(String text, {int length = 1023}) {
    var startIdx = 0;
    var endIdx = 0;
    final chunks = <String>[];
    var lyrics = text;
    if (!lyrics.endsWith('\n')) {
      lyrics = lyrics + '\n';
    }

    while (endIdx < lyrics.length) {
      endIdx = rfind(lyrics, '\n', startIdx, startIdx + length - 1) + 1;
      if (endIdx == 0) {
        endIdx = startIdx + length;
      }
      chunks.add(lyrics.substring(startIdx, endIdx));
      startIdx = endIdx;
    }
    return chunks;
  }

  /// dart implementation of python rfind
  static int rfind(String text, String subString, int startIdx, int endIdx) {
    if (startIdx < 0) startIdx = 0;
    if (endIdx >= text.length) endIdx = text.length - 1;

    for (var i = endIdx; i >= startIdx; i--) {
      if (text.substring(i, i + subString.length) == subString) {
        return i;
      }
    }

    return -1;
  }
}
