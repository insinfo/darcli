import 'dart:typed_data';
import 'package:new_sali_core/new_sali_core.dart';

import 'package:pdf_fork/pdf.dart';
import 'package:pdf_fork/widgets.dart';
import 'package:intl/intl.dart';

Future<Uint8List> geraPDFRelatorioAuditoria(List<Auditoria> auditorias) async {
  final logoUrlSvg = '/assets/images/brasao_editado_1.svg';
  var svgRaw = await SaliCoreUtils.getNetworkTextFile(logoUrlSvg);
  final svgImageLogo = SvgImage(svg: svgRaw);
  final pdf = Document();
  final now = DateTime.now();

  var headerTextStyle =
      TextStyle(fontSize: 10, color: PdfColor.fromInt(0xff2c3e50));

  pdf.addPage(
    MultiPage(
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
      build: (Context context) => <Widget>[
        Header(level: 1, text: 'Auditoria do Sistema'),

        // andamentos
        TableHelper.fromTextArray(
            columnWidths: {
              0: FixedColumnWidth(70),
              1: FixedColumnWidth(120),
              2: FixedColumnWidth(130),
              3: FixedColumnWidth(130),
              4: FixedColumnWidth(130),
              5: IntrinsicColumnWidth(),
              6: FixedColumnWidth(115),
            },
            context: context,
            data: <List<String>>[
              <String>[
                'CGM',
                'Usuário',
                'Módulo',
                'Funcionalidade',
                'Ação',
                'Objeto',
                'Data'
              ],
              ...auditorias.map((aud) {
                return [
                  aud.numCgm.toString(),
                  aud.username != null ? aud.username! : '',
                  aud.nomModulo != null ? aud.nomModulo! : '',
                  aud.nomFuncionalidade != null ? aud.nomFuncionalidade! : '',
                  aud.nomAcao != null ? aud.nomAcao! : '',
                  aud.objeto,
                  aud.dataFormatada,
                ];
              }).toList()
            ]),
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
