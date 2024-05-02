import 'dart:typed_data';
import 'package:new_sali_core/new_sali_core.dart';

import 'package:pdf_fork/pdf.dart';
import 'package:pdf_fork/widgets.dart';
import 'package:intl/intl.dart';

Future<Uint8List> geraPDFListagemProcessos(
  List<Processo> processos,
  String username,
  int idListagem,
  String listagemAnoExercicio,{int limitApensos =40}) async {
  final logoUrlSvg = '/assets/images/brasao_editado_1.svg';
  final svgRaw = await SaliCoreUtils.getNetworkTextFile(logoUrlSvg);
  final svgImage = SvgImage(svg: svgRaw);
  final pdf = Document();
  final now = DateTime.now();

  final headerTextStyle =
      TextStyle(fontSize: 10, color: PdfColor.fromInt(0xff2c3e50));

  // var bodyTextStyle = TextStyle(
  //     fontSize: 13,
  //     color: PdfColor.fromInt(0xff000000),
  //     fontWeight: FontWeight.bold);

  // var bodyTextStyleLabel =
  //     TextStyle(fontSize: 13, color: PdfColor.fromInt(0xff000000));

  pdf.addPage(MultiPage(
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
                Text('Rua Campo do Albacora, nº 75 - Loteamento Atlântica',
                    style: headerTextStyle),
                Text('CEP: 28895-664 | Tel.: (22) 2771-1515',
                    style: headerTextStyle),
                Text('Usuário que emitiu: $username', style: headerTextStyle),
                Text(
                    '''Emissão: ${DateFormat("dd/MM/yyyy 'às' HH:mm").format(now)}   |   Página: ${context.pageNumber} de ${context.pagesCount}''',
                    style: headerTextStyle),
                Row(children: [
                  Text('Código Listagem de Processos: ',
                      style: headerTextStyle),
                  Text('${idListagem}/$listagemAnoExercicio',
                      style: headerTextStyle.copyWith(
                          fontWeight: FontWeight.bold)),
                ]),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            SizedBox(
              height: 80,
              width: 150,
              child: svgImage, //svgImage, //Image(imageLogo),
            )
          ],
        );
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text('Página ${context.pageNumber} de ${context.pagesCount}',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (Context context) => <Widget>[
            Header(level: 1, text: 'Protocolo - Listagem de Processos'),
            Padding(padding: const EdgeInsets.all(10)),
            TableHelper.fromTextArray(
                columnWidths: {
                  0: FixedColumnWidth(75),
                  1: FixedColumnWidth(120),
                  2: IntrinsicColumnWidth(),
                  3: FixedColumnWidth(95),
                },
                context: context,
                data: <List<String>>[
                  <String>['Processo', 'Assunto', 'Requerente', 'Data/Hora'],
                  ...processos
                      .map((pro) => [
                            '${pro.codProcesso}/${pro.anoExercicio}',
                            pro.nomAssunto ?? '',
                            pro.nomeInteressado ?? '',
                            pro.dataInclusaoFormatada
                          ])
                      .toList(),
                ]),
            // Table(columnWidths: {
            //   1: FixedColumnWidth(120),
            //   2: IntrinsicColumnWidth(),
            //   3: IntrinsicColumnWidth(),
            // }, children: [
            //   TableRow(children: [
            //     Container(
            //       alignment: Alignment.center,
            //       padding: EdgeInsets.all(2),
            //       constraints: BoxConstraints(minHeight: 20),
            //       child: Text('Processo'
            //           //style: TextStyle(),
            //           //textAlign: textAlign,
            //           ),
            //     ),
            //   ]),
            // ]),
            Padding(padding: const EdgeInsets.all(20)),          
          
          ]));

  //save PDF
  final bytes = await pdf.save();
  // if (isDownload) {
  //   FrontUtils.downloadFile(
  //       bytes, 'Listagem de Processos.pdf', 'application/pdf');
  // }
  // if (isPrint) {
  //   FrontUtils.printFileBytes(bytes, 'application/pdf');
  // }

  return bytes;
}
