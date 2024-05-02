import 'dart:typed_data';
import 'package:new_sali_core/new_sali_core.dart';

import 'package:pdf_fork/pdf.dart';
import 'package:pdf_fork/widgets.dart';
import 'package:intl/intl.dart';

Future<Uint8List> geraPDFAndamentosProcesso(
    Processo processo, List<Andamento> andamentosP, String username) async {
  List<Andamento> andamentos = [...andamentosP];
//  andamentos.sort((a, b) => b.codAndamento.compareTo(a.codAndamento));
  final numProcesso =
      '${andamentos.first.codProcesso}/${andamentos.first.anoExercicio}';

  final logoUrlSvg = '/assets/images/brasao_editado_1.svg';
  final svgRaw = await SaliCoreUtils.getNetworkTextFile(logoUrlSvg);
  final svgImageLogo = SvgImage(svg: svgRaw);
  final pdf = Document();
  final now = DateTime.now();

  final headerTextStyle =
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
               
                Text('E-mail: webmaster@site',
                    style: headerTextStyle),
                Text('Usuário: $username', style: headerTextStyle),
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
        Header(level: 1, text: 'Andamentos do Processo ${numProcesso}'),

        // andamentos
        TableHelper.fromTextArray(
            columnWidths: {
              0: FixedColumnWidth(65),
              1: FixedColumnWidth(120),
              2: FixedColumnWidth(150),
              3: IntrinsicColumnWidth(),
              4: FixedColumnWidth(135),
              5: IntrinsicColumnWidth(),
            },
            context: context,
            data: <List<String>>[
              <String>[
                'Nº ',
                'Data Andamento',
                'Nome CGM Andamento',
                'Nome Setor Destino',
                'Data Recebimento',
                'Nome CGM Recebimento'
              ],
              ...andamentos.map((anda) {
                return [
                  anda.codAndamento.toString(),
                  anda.dataAndamentoFormatada,
                  anda.nomeCgmAndamento ?? '',
                  anda.nomeSetorDestino ?? '',
                  anda.dataRecebimentoFormatada,
                  anda.nomeCgmRecebimento ?? '',
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
            child: Text(
                'Sistema  - 2023 - Desenvolvido pela office de city',
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
