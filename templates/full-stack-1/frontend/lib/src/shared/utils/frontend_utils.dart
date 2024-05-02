import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Dimension {
  int width;
  int height;
  Dimension({
    required this.width,
    required this.height,
  });
}

class Position {
  int x;
  int y;
  Position({
    required this.x,
    required this.y,
  });
}

class FrontUtils {
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

  static bool blacklistedCPF(String cpf) {
    return cpf == '11111111111' ||
        cpf == '22222222222' ||
        cpf == '33333333333' ||
        cpf == '44444444444' ||
        cpf == '55555555555' ||
        cpf == '66666666666' ||
        cpf == '77777777777' ||
        cpf == '88888888888' ||
        cpf == '99999999999';
  }

  static bool validarCPF(String? cpf) {
    if (cpf == null) {
      return false;
    } else if (cpf == '') {
      return false;
    } else if (cpf.length < 11) {
      return false;
    }

    var sanitizedCPF = cpf
        .replaceAll(RegExp(r'\.|-'), '')
        .split('')
        .map((String digit) => int.parse(digit))
        .toList();

    if (sanitizedCPF.length < 11) {
      return false;
    }

    if (blacklistedCPF(sanitizedCPF.join())) {
      return false;
    }

    var result = sanitizedCPF[9] ==
            gerarDigitoVerificador(sanitizedCPF.getRange(0, 9).toList()) &&
        sanitizedCPF[10] ==
            gerarDigitoVerificador(sanitizedCPF.getRange(0, 10).toList());

    return result;
  }

  static List<int> randomizer(int size) {
    var random = <int>[];
    for (var i = 0; i < size; i++) {
      random.add(Random().nextInt(9));
    }
    return random;
  }

  static String gerarCPF({bool formatted = false}) {
    var n = randomizer(9);
    n
      ..add(gerarDigitoVerificador(n))
      ..add(gerarDigitoVerificador(n));
    return formatted ? formatCPF(n) : n.join();
  }

  static String formatCPF(List<int> n) =>
      '${n[0]}${n[1]}${n[2]}.${n[3]}${n[4]}${n[5]}.${n[6]}${n[7]}${n[8]}-${n[9]}${n[10]}';

  static int gerarDigitoVerificador(List<int> digits) {
    var baseNumber = 0;
    for (var i = 0; i < digits.length; i++) {
      baseNumber += digits[i] * ((digits.length + 1) - i);
    }
    var verificationDigit = baseNumber * 10 % 11;
    return verificationDigit >= 10 ? 0 : verificationDigit;
  }

  static String sanitizedCPF(cpf) {
    return cpf.replaceAll(RegExp(r'\.|-'), '');
  }

  /// Formatar número de CNPJ
  static String? formatCnpj(String? cnpj) {
    if (cnpj == null) return null;

    // Obter somente os números do CNPJ
    var numeros = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    // Testar se o CNPJ possui 14 dígitos
    if (numeros.length != 14) return cnpj;

    // Retornar CPF formatado
    return '${numeros.substring(0, 2)}.${numeros.substring(2, 5)}.${numeros.substring(5, 8)}/${numeros.substring(8, 12)}-${numeros.substring(12)}';
  }

  /// Validar número de CNPJ
  static bool validarCnpj(String? cnpj) {
    if (cnpj == null) return false;

    // Obter somente os números do CNPJ
    var numeros = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    // Testar se o CNPJ possui 14 dígitos
    if (numeros.length != 14) return false;

    // Testar se todos os dígitos do CNPJ são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(numeros)) return false;

    // Dividir dígitos
    var digitos = numeros.split('').map((String d) => int.parse(d)).toList();

    // Calcular o primeiro dígito verificador
    var calc_dv1 = 0;
    var j = 0;
    for (var i in Iterable<int>.generate(12, (i) => i < 4 ? 5 - i : 13 - i)) {
      calc_dv1 += digitos[j++] * i;
    }
    calc_dv1 %= 11;
    var dv1 = calc_dv1 < 2 ? 0 : 11 - calc_dv1;

    // Testar o primeiro dígito verificado
    if (digitos[12] != dv1) return false;

    // Calcular o segundo dígito verificador
    var calc_dv2 = 0;
    j = 0;
    for (var i in Iterable<int>.generate(13, (i) => i < 5 ? 6 - i : 14 - i)) {
      calc_dv2 += digitos[j++] * i;
    }
    calc_dv2 %= 11;
    var dv2 = calc_dv2 < 2 ? 0 : 11 - calc_dv2;

    // Testar o segundo dígito verificador
    if (digitos[13] != dv2) return false;

    return true;
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

//   function convertToMaskInput(regex) {
//   return new RegExp(regex).source
//     .replace(/^\^|\$$/g, '')
//     .replace(/\\d/g, '#')
//     .replace(/\(([^)]*)\)|\[([^^])\]|\\([\\/.(){}[\]])/g, '$1$2$3')
//     .replace(/([\w#.-])\{(\d+)\}/gi, function (_, c, n) {
//         return Array(+n + 1).join(c)
//     })
// }
// convertToMaskInput("^\d{4}$")
// console.log([
//   /^\d{3}$/, //=> "###"
//   /^(GB)\d{3}$/, //=> "GB###"
//   /^\d{2}\.\d{3}\/\d{4}-\d{2}$/, //=> "##.###/####-##"
//   /^\d{2}[ ]\d{3}[ ]\d{3}$/ //=> "## ### ###"
// ].map(convertToMaskInput))

  /// get Html Element width | height
  static Dimension getElementSize(Element element, {bool isComputed = false}) {
    var display = element.style.display;
    var width = 0;
    var height = 0;
    if (display != 'none') // Safari bug
    {
      width = element.offsetWidth;
      height = element.offsetHeight;
    } else {
      // All *Width and *Height properties give 0 on elements with display none,
      // so enable the element temporarily
      var els = element.style;
      var originalVisibility = els.visibility;
      var originalPosition = els.position;
      var originalDisplay = els.display;
      els.visibility = 'hidden';
      els.position = 'absolute';
      els.display = 'block';
      var originalWidth = element.clientWidth;
      var originalHeight = element.clientHeight;
      els.display = originalDisplay;
      els.position = originalPosition;
      els.visibility = originalVisibility;
      width = originalWidth;
      height = originalHeight;
    }

    if (isComputed) {
      var comStyle = element.getComputedStyle();
      var w = comStyle.getPropertyValue("width");
      var h = comStyle.getPropertyValue("height");

      width = double.parse(w == '' ? '0' : w.replaceAll('px', '')).floor();
      height = double.parse(h == '' ? '0' : h.replaceAll('px', '')).floor();
    }

    return Dimension(width: width, height: height);
  }

  /// use getCanvasFont(element) to [font] argument
  static num getTextWidth(String text, String font) {
    // re-use canvas object for better performance
    var canvas = document.createElement('canvas') as CanvasElement;
    var context = canvas.context2D;
    context.font = font;
    var metrics = context.measureText(text);
    return metrics.width ?? 0;
  }

  static String? getCssStyle(Element element, String prop) {
    var propVal = element.getComputedStyle().getPropertyValue(prop);
    return propVal == '' ? null : propVal;
  }

  static String getCanvasFont(Element element) {
    var fontWeight = getCssStyle(element, 'font-weight') ?? 'normal';
    var fontSize = getCssStyle(element, 'font-size') ?? '16px';
    var fontFamily = getCssStyle(element, 'font-family') ??
        'Times New Roman'; //'Times New Roman'
    return '${fontWeight} ${fontSize} ${fontFamily}';
  }

  static Position getOffset(Element el) {
    var targetPosition = el.getBoundingClientRect();
    var x = (targetPosition.left + window.scrollX).round();
    var y = (targetPosition.top + window.scrollY).round();
    return Position(x: x, y: y);
  }

  static downloadFile(Uint8List bytes, String fileName, String type) {
    //= await pdf.save();
    final blob = Blob([bytes], type);
    final url = Url.createObjectUrlFromBlob(blob);
    //open(url, target, windowFeatures)
    //html.window.open(url, '_blank','Guia de Encaminhamento.pdf');
    var anchor = AnchorElement(href: url);
    //anchor.style.display = 'none';
    anchor.download = fileName;
    anchor.click();
    //Url.revokeObjectUrl(url);
  }

  static downloadFile2(List<int> bytes, String fileName, String type) {
    //= await pdf.save();
    final blob = Blob([bytes], type);
    final url = Url.createObjectUrlFromBlob(blob);
    //open(url, target, windowFeatures)
    //html.window.open(url, '_blank','Guia de Encaminhamento.pdf');
    var anchor = AnchorElement(href: url);
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

  static Future<Uint8List> readFileAsUint8(File file) async {
    var completer = Completer<Uint8List>();
    var reader = FileReader();
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as Uint8List);
    });
    reader.readAsArrayBuffer(file);

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
          document.getElementById('printFrame')?.remove();
        })
      ]);
    });
  }

  /// so funciona com PDF/HTML/TXT/XML
  static Future<void> printFileBytes(Uint8List bytes, String type) async {
    final completer = Completer();
    final blob = Blob([bytes], type);
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

    var isOverflow = (Element el) {
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
    };

    // var displayFlex = (Element el) {
    //   var display = el.getComputedStyle().display;
    //   return display == 'flex';
    // };

    var thisEl = element;
    //if (initEl == null) print('** Overflow check commence! $thisEl');
    var origEl = initEl ?? thisEl;
    if (isOverflow(thisEl)) {
      //consoleLog(thisEl);
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
