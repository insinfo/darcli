/*import 'dart:html';
import 'package:new_sali_core/new_sali_core.dart';
import 'package:new_sali_frontend/src/shared/js_interop/workarounds.dart';

const Map<String, String> hTStyle = const {
  'margin-bottom': '0',
  'font-size': '10px',
  'font-weight': 'normal',
  'margin-top': '0',
  'padding': '0',
};

const Map<String, String> h1TStyle = const {
  'margin-bottom': '0',
  'font-size': '13px',
  'font-weight': 'normal',
  'border-bottom': 'solid 1px #000',
  'width': '100%',
  'margin-top': '0',
  'padding': '0',
};

const Map<String, String> tableStyle = const {
  'font-size': '16px',
  'font-family': '"Trebuchet MS", Arial, Helvetica, sans-serif',
  'border-collapse': 'collapse',
  'border-spacing': '0',
  'width': '100%',
};

Future<void> geraHtmlGuiaEncaminhamento(
  List<Processo> processos,
  String username,
  String nomeSetorDestino,
  String? nomeSetorOrigem, {
  bool isPrint = false,
  bool isDownload = true,
}) async {
  //final logoUrlSvg = 'logo_PMRO_Sali_3-01.svg';
  final logoUrlSvg = '/assets/images/brasao_editado_1.svg';

  //a4 aspect ratio 1.414
  var divPage = Container(children: [
    Header(children: [
      Column(children: [
        Text('office Municipal de city'),
        Text('Rua Campo do Albacora, nº 75 - Loteamento Atlântica'),
        Text('CEP: 28895-664 | Tel.: (22) 2771-1515'),
        Text('Usuário: isaque.santana'),
        Text('Emissão: 08/03/2023 às 18:57'),
      ]),
      Column(children: [
        Image(logoUrlSvg, style: {'width': '250px'}),
      ]),
    ]),
    Heading1('Protocolo - Guia de Encaminhamento'),
    Space(),
    LabelValue('Origem:', 'TI - Tecnologia da Informação'),
    Space(),
    Padding(
      child: Table([
        <String>['Processo', 'Assunto', 'Requerente'],
        <String>['5465/5465', 'dfg', 'dfg'],
      ]),
    ),
  ], style: {
    'aspect-ratio': '1.414',
    'width': '100%',
    'background': '#fff',
    //'z-index': '50000',
    'margin': '0 auto',
    'padding': '10px',
    'line-height': '1.5715',
    'font-family':
        '"Inter",system-ui,-apple-system,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans","Liberation Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji"',
  });

  //document.body!.querySelector('encaminhar-processo-page')!.append(divPage);

  var iframe = IFrameElement();

  document.body!.append(iframe);

  await iframe
      .writeHtml('<body style="margin: 0;">${divPage.outerHtml}</body>');

  iframe.print();
}

Element Text(String text, {Map<String, String>? style = hTStyle}) {
  var el = HeadingElement.h6()..text = text;
  style?.forEach((key, value) {
    el.style.setProperty(key, value);
  });
  return el;
}

Element Padding({required Element child, String padding = '10px'}) {
  var el = DivElement();
  el.style.padding = padding;
  el.append(child);
  // style?.forEach((key, value) {
  //   el.style.setProperty(key, value);
  // });
  return el;
}

Element Table(List<List<String>> data,
    {Map<String, String>? style = tableStyle}) {
  var el = TableElement();
  var count = 0;
  for (var row in data) {
    var tr = TableRowElement();
    for (var col in row) {
      var td = count == 0 ? document.createElement('th') : TableCellElement();
      td.text = col;
      td.style.border = '1px solid';
      tr.append(td);
    }
    el.append(tr);
    count++;
  }

  style?.forEach((key, value) {
    el.style.setProperty(key, value);
  });
  return el;
}

Element Space(
    {int height = 10, int? width, Map<String, String>? style = hTStyle}) {
  var el = DivElement();
  el.style.height = '${height}px';
  if (width != null) {
    el.style.width = '${width}px';
  }
  style?.forEach((key, value) {
    el.style.setProperty(key, value);
  });
  return el;
}

Element LabelValue(String labelText, String valueText,
    {Map<String, String>? style}) {
  var root = ParagraphElement();
  root.style.fontSize = '1.2rem';

  var label = SpanElement()..text = labelText;
  label.style.marginRight = '10px';

  var value = SpanElement()..text = valueText;
  value.style.fontWeight = '600';

  root.append(label);
  root.append(value);

  style?.forEach((key, value) {
    root.style.setProperty(key, value);
  });
  return root;
}

Element Heading1(String text, {Map<String, String>? style = h1TStyle}) {
  var el = HeadingElement.h1()..text = text;
  style?.forEach((key, value) {
    el.style.setProperty(key, value);
  });
  return el;
}

Element Image(String url, {Map<String, String>? style}) {
  var el = ImageElement(src: url);

  el.style.padding = '10px';

  style?.forEach((key, value) {
    el.style.setProperty(key, value);
  });

  return el;
}

DivElement Row({List<Element>? children, Map<String, String>? style}) {
  var div = DivElement();

  if (children != null) {
    children.forEach((element) {
      div.append(element);
    });
  }

  div.style.setProperty('display', 'flex');
  div.style.flexDirection = 'row';
  style?.forEach((key, value) => div.style.setProperty(key, value));
  return div;
}

DivElement Header(
    {List<Element>? children,
    justifyContent = 'space-between',
    alignItems = 'center',
    Map<String, String>? style}) {
  var div = DivElement();

  if (children != null) {
    children.forEach((element) {
      div.append(element);
    });
  }
  div.style.justifyContent = justifyContent;
  div.style.setProperty('align-items', alignItems);
  div.style.setProperty('display', 'flex');
  div.style.flexDirection = 'row';
  div.style.marginBottom = '20px';

  style?.forEach((key, value) => div.style.setProperty(key, value));
  return div;
}

DivElement Column({List<Element>? children, Map<String, String>? style}) {
  var div = DivElement();

  if (children != null) {
    children.forEach((element) {
      div.append(element);
    });
  }
  div.style.setProperty('width', 'fit-content');
  // div.style.setProperty('display', 'flex');
  // div.style.flexDirection = 'column';
  style?.forEach((key, value) => div.style.setProperty(key, value));
  return div;
}

DivElement Container({List<Element>? children, Map<String, String>? style}) {
  var div = DivElement();

  if (children != null) {
    children.forEach((element) {
      div.append(element);
    });
  }
  style?.forEach((key, value) {
    div.style.setProperty(key, value);
  });
  return div;
}
*/