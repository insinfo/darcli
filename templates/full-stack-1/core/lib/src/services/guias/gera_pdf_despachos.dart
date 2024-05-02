import 'dart:typed_data';
import 'package:new_sali_core/new_sali_core.dart';
//import 'package:new_sali_core/src/utils/htmltopdfwidgets/html_to_widgets_codec.dart';

import 'package:pdf_fork/pdf.dart';
import 'package:pdf_fork/widgets.dart';
import 'package:intl/intl.dart';

import '../../utils/pdf_utils.dart';

Future<Uint8List> geraPDFDespachos(
    Processo processo, List<Despacho> despachos) async {
  final numProcesso = '${processo.codProcesso}/${processo.anoExercicio}';

  final logoUrlSvg = '/assets/images/brasao_editado_1.svg';
  final svgRaw = await SaliCoreUtils.getNetworkTextFile(logoUrlSvg);
  final svgImageLogo = SvgImage(svg: svgRaw);
  final pdf = Document();
  final now = DateTime.now();

  final headerTextStyle =
      TextStyle(fontSize: 10, color: PdfColor.fromInt(0xff2c3e50));

  final bodyTextStyleLabel =
      TextStyle(fontSize: 11, color: PdfColor.fromInt(0xff000000));

  final despachosWidgets = <Widget>[];

  for (var desp in despachos) {
    despachosWidgets.add(Column(children: [
      // testo do despacho
      // Text(StringUtils.stripHtml(desp.descricao),
      //     style: bodyTextStyleLabel),

      ...breakTextWidget(StringUtils.stripHtmlIfNeeded(desp.descricao,replaceMultiLineBreaksWithTwo:true),
          style: bodyTextStyleLabel, limit: 1000),

     // ...await HTMLToPdf().convert(desp.descricao),

      SizedBox(width: 15, height: 15),
      Text('Despachado por: ${desp.nomeCgmDespacho}',
          style: bodyTextStyleLabel),
      SizedBox(width: 8, height: 8),
      Text('Despachado em: ${desp.dataDespachoFormatada}',
          style: bodyTextStyleLabel),
      SizedBox(width: 25, height: 25),
    ]));
  }

  pdf.addPage(
    MultiPage(
      maxPages: 200,
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 1.0 * PdfPageFormat.cm,
        marginLeft: 1.0 * PdfPageFormat.cm,
        marginRight: 1.0 * PdfPageFormat.cm,
        marginBottom: 1.0 * PdfPageFormat.cm,
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Row(
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
          ),
        );
      },
      build: (Context context) => <Widget>[
        Header(
            level: 1,
            text:
                'Despachos do andamento selecionado do processo ${numProcesso}'),
        ...despachosWidgets,
      ],
      footer: (Context context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: PdfColors.grey))),
          //alignment: Alignment.centerRight,
          // margin: EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
          child: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text('Sistema  - 2023',
                style: TextStyle(fontSize: 9, color: PdfColors.grey)),
          ),
        );
      },
    ),
  );

  //save PDF
  final bytes = await pdf.save();
  // if (isDownload) {
  //   FrontUtils.downloadFile(
  //       bytes, 'Andamentos de Processo.pdf', 'application/pdf');
  // }
  // if (isPrint) {
  //   FrontUtils.printFileBytes(bytes, 'application/pdf');
  // }

  return bytes;
}
