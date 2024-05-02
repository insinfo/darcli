import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'dart:math';

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:sibem_frontend_site/sibem_frontend_site.dart';

class FrontUtils {
  static Future<http.Response> fetchWithAuthentication(
      String url, String authToken) async {
    final headers = {'Authorization': 'Bearer $authToken'};
    final response = await http.get(Uri.parse(url), headers: headers);
    return response;
  }

  /// [imageIdOrImageEle] String | ImageElement
  static Future<void> displayProtectedImage(
      dynamic imageIdOrImageEle, String imageUrl, String authToken) async {
    try {
      final response = await fetchWithAuthentication(imageUrl, authToken);
      final type = response.headers['content-type'];

      final blob = Blob([response.bodyBytes], type);
      final objectUrl = Url.createObjectUrlFromBlob(blob);

      final imageElement = imageIdOrImageEle is String
          ? document.getElementById(imageIdOrImageEle) as ImageElement
          : imageIdOrImageEle as ImageElement;

      imageElement.src = objectUrl;
      imageElement.onLoad.listen((_) {
        Url.revokeObjectUrl(objectUrl);
      });
      imageElement.onError.listen((e) {
        e.stopPropagation();
        imageElement.attributes['src'] = 'assets/images/no_user.jpg';
      });
      // void onImageNotFound(e) {
      // }
    } catch (e) {
      print('Error fetching or displaying image: $e');
    }
  }

  /// semelhante a object-fir: cover
  static Future<String> resizeImage(
      String imageUrl, int newWidth, int newHeight) async {
    final ImageElement img = await getNetworkFileAsImage(imageUrl);

    final imgWidth = img.width!;
    final imgHeight = img.height!;

    var x = 0;
    var y = 0;
    var w = newWidth;
    var h = newHeight;
    // default offset is center
    var offsetX = 0.5;
    var offsetY = 0.5;

    // keep bounds [0.0, 1.0]
    if (offsetX < 0) offsetX = 0;
    if (offsetY < 0) offsetY = 0;
    if (offsetX > 1) offsetX = 1;
    if (offsetY > 1) offsetY = 1;

    var iw = imgWidth,
        ih = imgHeight,
        r = min(w / iw, h / ih),
        nw = iw * r, // new prop. width
        nh = ih * r; // new prop. height
    num cx, cy, cw, ch = 1;
    num ar = 1;

    // decide which gap to fill
    if (nw < w) {
      ar = w / nw;
    }
    if ((ar - 1).abs() < 1e-14 && nh < h) {
      ar = h / nh; // updated
    }
    nw *= ar;
    nh *= ar;

    // calc source rectangle
    cw = iw / (nw / w);
    ch = ih / (nh / h);

    cx = (iw - cw) * offsetX;
    cy = (ih - ch) * offsetY;

    // make sure source rectangle is valid
    if (cx < 0) cx = 0;
    if (cy < 0) cy = 0;
    if (cw > iw) cw = iw;
    if (ch > ih) ch = ih;

    // fill image in dest. rectangle
    final canvas = CanvasElement(width: newWidth, height: newHeight);
    final ctx = canvas.getContext('2d') as CanvasRenderingContext2D;
    ctx.imageSmoothingEnabled = true;
    ctx.drawImageScaledFromSource(img, cx, cy, cw, ch, x, y, w, h);

    // final pica = newPica();
    // await pica.resizeF(img, canvas);
    final result = canvas.toDataUrl('image/png', 1);

    return result;
  }

  static double scaleToPercentage(
    num value,
    double minScale,
    double maxScale, {
    double minPercentage = 1,
    double maxPercentage = 200,
  }) {
    // Perform the conversion
    double percentage = ((value - minScale) / (maxScale - minScale)) *
            (maxPercentage - minPercentage) +
        minPercentage;

    return percentage;
  }

  static double percentageToScale(
    num percentage,
    double minScale,
    double maxScale, {
    double minPercentage = 1,
    double maxPercentage = 200,
  }) {
    // Define the minimum and maximum values in the original scale
    double minOriginal = minScale;
    double maxOriginal = maxScale;
    // Perform the reverse conversion
    double originalValue =
        ((percentage - minPercentage) / (maxPercentage - minPercentage)) *
                (maxOriginal - minOriginal) +
            minOriginal;

    return originalValue;
  }

  static String genId(String type) {
    final random = Random();
    final randomString =
        random.nextInt(pow(2, 32).toInt()).toRadixString(36).padLeft(9, '0');
    return '$type-$randomString';
  }

  /// copiar texto para area de transferencia
  static void copyToClipboard(String textToCopy) {
    final temp = InputElement();
    temp.type = 'text';
    temp.value = textToCopy;
    document.body?.append(temp);
    temp.select();
    document.execCommand('Copy');
    temp.remove();
  }

  /// [fileLimitInBytes] = 1048576 * 3 = 3 megabytes
  /// [accept] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" for XLSX
  /// return {'bytes': reader.result, 'name': file.name, 'size': file.size})
  static Future<Map<String, dynamic>?> getClientFileAsBytes(
      {String? accept =
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      int fileLimitInBytes = 1048576 * 3}) async {
    final completer = Completer<Map<String, dynamic>?>();
    final inputFile = FileUploadInputElement();
    inputFile.accept = accept;
    inputFile.multiple = false;
    inputFile.click();
    inputFile.onChange.listen((inputFileEvent) {
      if (inputFile.files?.isNotEmpty == true) {
        final file = inputFile.files!.first;
        print('This file size is: ${file.size / 1024 / 1024}MiB');
        if (file.size < fileLimitInBytes) {
          final reader = FileReader();
          reader.onLoad.listen((readerEvent) {
            completer.complete(
                {'bytes': reader.result, 'name': file.name, 'size': file.size});
          });
          reader.readAsArrayBuffer(inputFile.files!.first);
        } else {
          SimpleDialogComponent.showAlert(
              'Arquivo ultrapassou o limite de $fileLimitInBytes bytes');
          completer.complete(null);
        }
      } else {
        completer.complete(null);
      }
    });
    inputFile.addEventListener('cancel', (evt) {
      //print("You closed the file picker dialog without selecting a file.");
      completer.complete(null);
    });
    return completer.future;
  }

  static Future<dynamic> getClientFileAsString(
      {String? accept = 'application/json'}) async {
    final completer = Completer();
    final inputFile = FileUploadInputElement();
    inputFile.accept = accept;
    inputFile.click();

    inputFile.onChange.listen((inputFileEvent) {
      if (inputFile.files?.isNotEmpty == true) {
        final reader = FileReader();
        reader.onLoad.listen((readerEvent) {
          completer.complete(reader.result);
        });
        reader.readAsText(inputFile.files!.first);
      } else {
        completer.complete(null);
      }
    });

    inputFile.addEventListener('cancel', (evt) {
      //print("You closed the file picker dialog without selecting a file.");
      completer.complete(null);
    });

    return completer.future;
  }

  static Future<dynamic> getClientFileAsDataUrl() async {
    final completer = Completer();
    final inputFile = FileUploadInputElement();
    inputFile.click();
    inputFile.onChange.listen((inputFileEvent) {
      if (inputFile.files?.isNotEmpty == true) {
        final reader = FileReader();
        reader.onLoad.listen((readerEvent) {
          completer.complete(reader.result);
        });
        reader.readAsDataUrl(inputFile.files!.first);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  static Future<String?> getClientFileAsObjectUrl() async {
    final completer = Completer<String?>();
    final inputFile = FileUploadInputElement();
    inputFile.click();
    inputFile.onChange.listen((inputFileEvent) {
      if (inputFile.files?.isNotEmpty == true) {
        final url = Url.createObjectUrl(inputFile.files!.first);
        return completer.complete(url);
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  static String getClipboard() {
    final pasteTarget = document.createElement('div');
    pasteTarget.contentEditable = 'true';
    // ignore: unused_local_variable
    var actElem = document.activeElement?.append(pasteTarget).parentNode;
    pasteTarget.focus();
    document.execCommand('Paste', null, null);
    final paste = pasteTarget.innerText;
    pasteTarget.remove();
    return paste;
  }

  /// pega todo texto da area de transferencia
  /// so funciona com HTTPS
  static Future<String> getClipboardText() async {
    final permissionStatus = await window.navigator.permissions?.query({
      'name': 'clipboard-read',
    });

    if (permissionStatus?.state == 'denied') {
      print('FrontUtils@getClipboardText Not allowed to read clipboard.');
    }
    final data = await window.navigator.clipboard?.readText();
    return data ?? '';
  }

  /// Programmatically select all text in a contenteditable HTML element
  static void selectElementContents(Node el) {
    var range = document.createRange();
    range.selectNodeContents(el);
    var sel = window.getSelection();
    sel!.removeAllRanges();
    sel.addRange(range);
  }

  /// cola o html substituindo a seleção
  static void pasteHtmlAtCaret(String html) {
    var sel = window.getSelection();
    if (sel != null && sel.rangeCount != null) {
      var range = sel.getRangeAt(0);
      range.deleteContents();
      // var baseOffset = sel.baseOffset;
      //var extentOffset = sel.extentOffset;
//  expandedSelRange.setStart(currentAnchorNode!, currentAnchorOffset);
//     expandedSelRange.setEnd(currentAnchorNode!, currentFocusOffset);
      // Range.createContextualFragment() would be useful here but is
      // non-standard and not supported in all browsers (IE9, for one)
      var el = document.createElement('div');
      el.setInnerHtml(html, treeSanitizer: NodeTreeSanitizer.trusted);
      var frag = document.createDocumentFragment();
      Node? node;
      Node? lastNode;
      while ((node = el.firstChild) != null) {
        lastNode = frag.append(node!);
      }
      range.insertNode(frag);
      //print('pasteHtmlAtCaret lastNode $lastNode');
      // Preserve the selection
      if (lastNode != null) {
        selectElementContents(lastNode);
      }
    }
  }

  /// remove todas as tags HTML so deixa o texto puro
  static String stripTags(String htmlStr) {
    final parseHTML = DomParser().parseFromString(htmlStr, 'text/html');
    return parseHTML.documentElement?.innerText ?? '';
  }

  /// retorna uma lista de nomes de mês
  /// [day] date = "2021-10-25" . Date Format is yyyy-MM-dd.
  /// ```dart
  ///  print(getMonthsFromDayTillNow("2021-10-5")); //[October 2021, November 2021, December 2021, January 2022, February 2022]
  /// ```
  static List<String> getMonthsFromDayTillNow(String day) {
    // 2021-10-
    List<String> dateSplit = day.split("-");
    DateTime loopDateTime =
        DateTime(int.parse(dateSplit[0]), int.parse(dateSplit[1]), 28);
    DateTime currentDateTime = DateTime.now();
    List<String> months = [];
    while (loopDateTime.isBefore(currentDateTime)) {
      months.add("${getMonth(loopDateTime.month)} ${loopDateTime.year}");
      loopDateTime = loopDateTime.add(Duration(days: 5));
      loopDateTime = DateTime(loopDateTime.year, loopDateTime.month, 28);
    }
    months.add("${getMonth(currentDateTime.month)} ${currentDateTime.year}");
    return months;
  }

  static String getMonth(int monthNumber) {
    late String month;
    switch (monthNumber) {
      case 1:
        month = "janeiro";
        break;
      case 2:
        month = "fevereiro";
        break;
      case 3:
        month = "março";
        break;
      case 4:
        month = "abril";
        break;
      case 5:
        month = "maio";
        break;
      case 6:
        month = "junho";
        break;
      case 7:
        month = "julho";
        break;
      case 8:
        month = "agosto";
        break;
      case 9:
        month = "setembro";
        break;
      case 10:
        month = "outubro";
        break;
      case 11:
        month = "novembro";
        break;
      case 12:
        month = "dezembro";
        break;
    }
    return month;
  }

  static String addZero(int value) {
    return value < 10 ? '0$value' : '$value';
  }

  /// valida (22)99701-5305
  static bool isCelular(String? val) {
    var regexCel = r'^\(?[1-9]{2}\)? ?(?:[2-8]|9[1-9])[0-9]{3}\-?[0-9]{4}$';
    if (val == null) {
      return false;
    }
    return RegExp(regexCel).hasMatch(val);
  }

  /// valida (22)2771-5305
  static bool isTelFixo(String? val) {
    var regexFixo = r'^\(?[1-9]{2}\)? ?(?:[2-8]|[1-9])[0-9]{3}\-?[0-9]{4}$';
    if (val == null) {
      return false;
    }
    return RegExp(regexFixo).hasMatch(val);
  }

  static bool emailIsValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(email);
  }

  static String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

  /// converte uma mascara para um padrão de expressao regular
  ///
  /// ```dart
  /// var pattern = convertMaskToRegex('(xx)xxxx-xxxx', 'x')
  ///  pattern == ^\(\d{2}\)\d{4}\-\d{4}$
  /// ```
  static String convertMaskToRegex(String mask, String escapeCharacter) {
    var pattern = r'^';
    var caracteres = mask.split('');
    caracteres.add(r' ');
    var countEscape = 0;
    for (var i = 0; i < caracteres.length; i++) {
      var c = caracteres[i];
      if (c == escapeCharacter) {
        countEscape++;
      } else {
        // alphanumeric
        final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
        if (!validCharacters.hasMatch(c)) {
          if (c != ' ') {
            pattern += '\\$c';
          }
        } else {
          pattern += c;
        }
      }
      if ((i + 1) < caracteres.length && caracteres[i + 1] != escapeCharacter) {
        pattern += '\\d{$countEscape}';
        countEscape = 0;
      }
    }
    pattern += r'$';

    return pattern;
  }

  static Future<String> getNetworkTextFile(String url,
      {Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return response.body;
  }

  // static Future<bool> isValidUrl(String url) async {
  //   final completer = Completer<bool>();
  //   // final response = await window.fetch(url);
  //   window.fetch(url, {
  //     'mode': 'no-cors',
  //   }).then((response) {

  //     if (response.status == 200) {
  //       completer.complete(true);
  //     } else {
  //       completer.complete(false);
  //     }
  //   });

  //   return completer.future;
  // }

  static Future<bool> isValidUrl(String url) async {
    try {
      final response = await http
          .head(Uri.parse(url)); // Use http.head for efficient validation
      return response.statusCode == 200;
    } catch (e) {
      print('Error validating URL: $e'); // Log any errors
      return false;
    }
  }

  static Future<dynamic> getNetworkFileAsDataUri(String url,
      {Map<String, String>? headers}) async {
    final completer = Completer();

    final response = await http.get(Uri.parse(url), headers: headers);
    //content-type
    final contentType = response.headers['content-type'];

    final reader = FileReader();
    reader.onLoad.listen((readerEvent) {
      completer.complete(reader.result);
    });
    final blob = Blob([response.bodyBytes], contentType);
    reader.readAsDataUrl(blob);

    return completer.future;
  }

  static Future<ImageElement> getNetworkFileAsImage(String url,
      {Map<String, String>? headers}) async {
    final completer = Completer<ImageElement>();

    //final response = await http.get(Uri.parse(url), headers: headers);
    //content-type
    //final contentType = response.headers['content-type'];

    // final reader = FileReader();
    // reader.onLoad.listen((readerEvent) {
    //   completer.complete(reader.result);
    // });
    // final blob = Blob([response.bodyBytes], contentType);
    // reader.readAsDataUrl(blob);

    final img = ImageElement(src: url);
    img.crossOrigin = 'anonymous';
    //img.src = e.target.result;
    img.onLoad.listen((event) {
      completer.complete(img);
    });

    return completer.future;
  }

  /// usando Html XmlHttpRequest API
  static Future<String?> urlContentToDataUri(String url) async {
    final completer = Completer<String?>();
    Blob blob = await HttpRequest.request(url, responseType: 'blob')
        .then((request) => request.response);

    final reader = FileReader();
    reader.onLoad.listen((event) {
      var data = (reader.result as String?);
      //data = data?.substring(data.indexOf(',') + 1);
      completer.complete(data);
    });
    reader.readAsDataUrl(blob);
    return completer.future;
  }

  /// usando Html fetch API
  static Future<String?> urlContentToDataUri2(String url) async {
    final completer = Completer<String?>();
    Blob blob = await window.fetch(url, {
      'mode': 'no-cors',
    }).then((response) => response.blob());

    final reader = FileReader();
    reader.onLoad.listen((event) {
      var data = (reader.result as String?);
      //data = data?.substring(data.indexOf(',') + 1);
      completer.complete(data);
    });
    reader.readAsDataUrl(blob);
    return completer.future;
  }

  static Future<Uint8List> readFileAsUint8(File file) async {
    var completer = Completer<Uint8List>();
    var reader = FileReader();
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as Uint8List);
    });
    reader.readAsArrayBuffer(file);

    return completer.future;
  }

  static Future<dynamic> readFileAsDataUrl(File file) async {
    var completer = Completer<dynamic>();
    var reader = FileReader();
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result);
    });
    reader.readAsDataUrl(file);

    return completer.future;
  }

  static printFileHtml(String content) {
    var blob = Blob([], 'text/html');
    final url = Url.createObjectUrlFromBlob(blob);

    document.getElementById('printFrame')?.remove();

    var printFrame = IFrameElement();
    printFrame.src = url;
    printFrame.id = 'printFrame';
    document.body!.append(printFrame);

    printFrame.style.display = 'none';
    printFrame.onLoad.listen((event) {
      var printPage = js.JsObject.fromBrowserObject(printFrame)['contentWindow']
          ['print'] as js.JsFunction;
      printPage.apply(<dynamic>[]);

      var addEventListener =
          js.JsObject.fromBrowserObject(printFrame)['contentWindow']
              ['addEventListener'] as js.JsFunction;

      addEventListener.apply([
        'afterprint',
        js.allowInterop((mql) {
          print('afterprint event $mql');
          document.getElementById('printFrame')?.remove();
        })
      ]);
    });
  }

  /// [mimiType] application/pdf | application/json ...
  static void download(dynamic data, String mimiType, String fileName) {
    final blob = Blob([data], mimiType);
    final url = Url.createObjectUrlFromBlob(blob);
    final anchor = AnchorElement()..href = url;
    anchor.download = fileName;
    document.body?.children.add(anchor);
    anchor.click();
    js.context.callMethod('setTimeout', [
      () => Url.revokeObjectUrl(url),
      100 // Delay to ensure download starts
    ]);
  }

  /// so funciona com PDF/HTML/TXT/XML
  /// [mimiType] application/pdf ...
  static Future<void> printFileBytes(Uint8List bytes, String mimiType) async {
    final completer = Completer();
    final blob = Blob([bytes], mimiType);
    final url = Url.createObjectUrlFromBlob(blob);

    if (window.navigator.userAgent.contains('Chrome')) {
      document.getElementById('printIFrame')?.remove();
      final printIFrame = IFrameElement();
      printIFrame.src = url;
      printIFrame.id = 'printIFrame';
      document.body!.append(printIFrame);
      printIFrame.style.display = 'none';
      printIFrame.onLoad.listen((event) {
        // Future.delayed(Duration(milliseconds: 1000), () {
        //   js_interop.printIframe('#printIFrame');
        // });
        final printPage =
            js.JsObject.fromBrowserObject(printIFrame)['contentWindow']['print']
                as js.JsFunction;
        printPage.apply(<dynamic>[]);
        completer.complete();
      });
    } else {
      //window.open(url, 'PDF');
      AnchorElement(href: url)
        ..target = '_blank'
        ..click();
      // o firefox usando o viewer do PDF.js imprime o PDF como imagem
      // final host = window.location.host;
      // final printIFrame = IFrameElement();
      // printIFrame.style.display = 'none';
      // printIFrame.src =
      //     '//$host/assets/js/pdfjs-viewer/web/viewer.html?file=$url';
      // printIFrame.id = 'printIFrame';
      // document.body!.append(printIFrame);
      // printIFrame.onLoad.listen((event) {
      //   Future.delayed(Duration(milliseconds: 1000), () {
      //     printIFrame.contentWindow?.postMessage('print', '*');
      //     completer.complete();
      //   });
      // });
    }

    //    <script>
    //   window.addEventListener("message", receiveMessage, false);

    //   function receiveMessage(event) {
    //     let msg = event.data;
    //     //console.log('viewer.html receiveMessage: ', event.data);
    //     if(msg == 'print'){
    //       window.print();
    //     }

    //   }
    // </script>

    //width: 1px; height: 100px; position: fixed; left: -1px; top: 0px; opacity: 0; border-width: 0px; margin: 0px; padding: 0px; visibility: hidden;
    // js_interop.iframeAfterPrint('#printIFrame', js.allowInterop((e) {
    //   print('dart afterprint event ');
    // }));

    return completer.future;
  }

  /// localiza o primeiro elemento parent ancestral da arvore DOM que tenha rolagem
  static Element? findOverflowParent(Element element, [Element? initEl]) {
    // var notVisible = (Element el) {
    //   var overflow = el.getComputedStyle().overflow;
    //   return overflow != 'visible';
    // };

    isOverflow(Element el) {
      var style = el.getComputedStyle();
      var overflow = style.overflow;
      var overflowX = style.overflowX;
      var overflowY = style.overflowY;
      return overflow == 'auto' ||
          overflow == 'scroll' ||
          overflowX == 'auto' ||
          overflowX == 'scroll' ||
          overflowY == 'auto' ||
          overflowY == 'scroll';
    }

    var thisEl = element;

    var origEl = initEl ?? thisEl;
    if (isOverflow(thisEl)) {
      //print("Overflow found on:" + thisEl.tagName);
      return thisEl;
    }
    //if (displayFlex(thisEl)) print("Flex found on: " + thisEl.tagName);
    if (thisEl.parent != null) {
      return findOverflowParent(thisEl.parent!, origEl);
    }
    return null;
  }
}
