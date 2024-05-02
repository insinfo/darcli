import 'package:esic_core/esic_core.dart';
import 'package:esic_frontend/src/shared/utils/utils.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

//import 'package:barcode/barcode.dart';

/// Download an image from the network.
Future<ImageProvider> networkImage(
  String url, {
  Map<String, String>? headers,
  PdfImageOrientation? orientation,
  double? dpi,
}) async {
  var response = await http.get(Uri.parse(url), headers: headers);
  return MemoryImage(response.bodyBytes, orientation: orientation, dpi: dpi);
}

Future<void> geraPdfSolicitacao(
    Solicitacao solicitacao, Solicitante solicitante,
    {bool isPrint = false, bool isDownload = true}) async {
  
  final logoUrlSvg = 'imagens/brasao_editado_1.svg';
  final svgRaw = await Utils.getNetworkTextFile(logoUrlSvg);
  final svgImageLogo = SvgImage(svg: svgRaw);
  final pdf = Document();
  final now = DateTime.now();

  final headerTextStyle =
      TextStyle(fontSize: 10, color: PdfColor.fromInt(0xff2c3e50));

  final bodyTextStyle = TextStyle(
      fontSize: 11,
      color: PdfColor.fromInt(0xff000000),
      fontWeight: FontWeight.bold);

  final bodyTextStyleLabel =
      TextStyle(fontSize: 11, color: PdfColor.fromInt(0xff000000));
  //var mainAxisSize = MainAxisSize.max;
  pdf.addPage(
    MultiPage(
      maxPages: 4000,
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 1.0 * PdfPageFormat.cm,
        marginLeft: 1.0 * PdfPageFormat.cm,
        marginRight: 1.0 * PdfPageFormat.cm,
        marginBottom: 1.0 * PdfPageFormat.cm,
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text('office Municipal de city',
                    style: headerTextStyle),
              
                Text(
                    '''Emissão: ${DateFormat("dd/MM/yyyy 'às' HH:mm").format(now)}   |   Página: ${context.pageNumber} de ${context.pagesCount}''',
                    style: headerTextStyle),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            SizedBox(
              height: 80,
              width: 150,
              child: svgImageLogo, //svgImage, //Image(imageLogo),
            )
          ],
        );
      },
      build: (Context context) {
        return [
          Header(level: 2, text: 'Solicitante'),
          ListView(spacing: 2, children: [
            Wrap(
                direction: Axis.horizontal,
                spacing: 7.0, // gap between adjacent chips
                runSpacing: 7.0, // gap between lines
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Nome: ', style: bodyTextStyleLabel),
                    Text(solicitante.nome, style: bodyTextStyle),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('CPF/CNPJ: ', style: bodyTextStyleLabel),
                    Text(
                        Utils.hidePartsOfString(solicitante.cpfCnpj,
                            visibleCharacters: 5),
                        style: bodyTextStyle),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('E-mail: ', style: bodyTextStyleLabel),
                    Text(Utils.uncensored(solicitante.email),
                        style: bodyTextStyle),
                  ]),
                ]),
          ]),
          SizedBox(height: 20),
          Header(level: 2, text: 'Informação da Solicitação'),
          ListView(spacing: 2, children: [
            Wrap(
                direction: Axis.horizontal,
                spacing: 7.0, // gap between adjacent chips
                runSpacing: 7.0, // gap between lines
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Numero Protocolo: ', style: bodyTextStyleLabel),
                    Text(solicitacao.protocoloText, style: bodyTextStyle),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Situação: ', style: bodyTextStyleLabel),
                    Text(solicitacao.situacaoText, style: bodyTextStyle),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Tipo Solicitação: ', style: bodyTextStyleLabel),
                    Text('${solicitacao.tipoSolicitacao?.nome}',
                        style: bodyTextStyle),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Forma Retorno: ', style: bodyTextStyleLabel),
                    Text('${solicitacao.formaRetornoText}',
                        style: bodyTextStyle),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Data da Solicitação: ', style: bodyTextStyleLabel),
                    Text('${solicitacao.dataSolicitacaoTextBr}',
                        style: bodyTextStyle),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Previsão Retorno: ', style: bodyTextStyleLabel),
                    Text('${solicitacao.dataPrevisaoRespostaTextBr}',
                        style: bodyTextStyle),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Solicitação Recebida em: ',
                        style: bodyTextStyleLabel),
                    Text('${solicitacao.dataRecebimentoSolicitacaoTextBr}',
                        style: bodyTextStyle),
                  ]),
                  SizedBox(height: 5, width: 5),
                ]),
          ]),
          SizedBox(height: 10, width: 10),
          Text('Solicitação: ', style: bodyTextStyleLabel),
          SizedBox(height: 20, width: 20),
          ..._breakTextWidget(solicitacao.textoSolicitacao,
              style: bodyTextStyle.copyWith(fontWeight: FontWeight.normal), limit: 1023),
          SizedBox(height: 20),
          if (solicitacao.dataResposta != null)
            Header(level: 2, text: 'Resposta'),
          if (solicitacao.dataResposta != null)
            ListView(spacing: 2, children: [
              Wrap(
                  direction: Axis.horizontal,
                  spacing: 7.0, // gap between adjacent chips
                  runSpacing: 7.0, // gap between lines
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Data Resposta: ', style: bodyTextStyleLabel),
                      Text('${solicitacao.dataRespostaTextBr}',
                          style: bodyTextStyle),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Respondido por: ', style: bodyTextStyleLabel),
                      Text('${solicitacao.usuarioResposta?.nome}',
                          style: bodyTextStyle),
                    ]),
                    SizedBox(height: 5, width: 5),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resposta: ', style: bodyTextStyleLabel),
                          SizedBox(height: 5, width: 5),
                          Text('${solicitacao.resposta}', style: bodyTextStyle),
                        ]),
                  ])
            ]),
        ];
      },
      footer: (Context context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: PdfColors.grey))),
          //alignment: Alignment.centerRight,
          // margin: EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
          child: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text('E-ESIC - 2023',
                style: TextStyle(fontSize: 9, color: PdfColors.grey)),
          ),
        );
      },
    ),
  );

  //save PDF
  var bytes = await pdf.save();
  if (isDownload) {
    Utils.downloadFile(bytes, 'Solicitação ${solicitacao.protocoloText}.pdf',
        'application/pdf');
  }
  if (isPrint) {
    Utils.printFileBytes(bytes, 'application/pdf');
  }
}

//bodyTextStyle Utils.truncateWithEllipsis(solicitacao.textoSolicitacao,length: 3500)
List<Widget> _breakTextWidget(String text,
    {int limit = 1023, TextStyle? style}) {
  if (text.length < limit) {
    return [Text(text, style: style)];
  } else {
    final items = <Widget>[];
    final chunks = Utils.slicesText(text, length: limit);
    for (var chunk in chunks) {
      items.add(Text(chunk, style: style));
    }

    return items;
  }
}

// List<String> _slices(String text, int chunkSize) {
//   final chunks = <String>[];

//   for (var i = 0; i < text.length; i += chunkSize) {
//     var endIndex = i + chunkSize;
//     if (endIndex > text.length) {
//       endIndex = text.length;
//     }
//     var chunk = text.substring(i, endIndex);
//     chunks.add(chunk);
//   }

//   return chunks;
// }
