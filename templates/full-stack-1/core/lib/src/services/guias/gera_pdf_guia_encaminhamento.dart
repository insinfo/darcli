import 'dart:typed_data';
import 'package:new_sali_core/new_sali_core.dart';

import 'package:pdf_fork/pdf.dart';
import 'package:pdf_fork/widgets.dart';
import 'package:intl/intl.dart';

Future<Uint8List> geraPDFGuiaEncaminhamento(
    List<Processo> processos,
    String username,
    String? nomeSetorOrigem,
    Setor setorDestino,
    int idListagem,
    String listagemAnoExercicio,
    {int limitApensos = 40}) async {
 

  final urlLogoPmroSvg = '/assets/images/brasao_editado_1.svg';
  final svgLogoPmroText =
      await SaliCoreUtils.getNetworkTextFile(urlLogoPmroSvg);
  final svgImageLogoPmro = SvgImage(svg: svgLogoPmroText);
  final pdf = Document();
  final now = DateTime.now();

  final headerTextStyle =
      TextStyle(fontSize: 10, color: PdfColor.fromInt(0xff2c3e50));

  final bodyTextStyle = TextStyle(
      fontSize: 13,
      color: PdfColor.fromInt(0xff000000),
      fontWeight: FontWeight.bold);

  final bodyTextStyleLabel =
      TextStyle(fontSize: 13, color: PdfColor.fromInt(0xff000000));

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
              child: svgImageLogoPmro, //svgImage, //Image(imageLogo),
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
            Header(level: 1, text: 'Protocolo - Guia de Encaminhamento'),
            if (nomeSetorOrigem != null)
              Row(children: [
                Text('Origem: ', style: bodyTextStyleLabel),
                Text(nomeSetorOrigem, style: bodyTextStyle),
              ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Destino: ', style: bodyTextStyleLabel),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('Orgão: ', style: bodyTextStyleLabel),
                            Text('${setorDestino.nomOrgao}',
                                style: bodyTextStyle),
                          ]),
                          Row(children: [
                            Text('Unidade: ', style: bodyTextStyleLabel),
                            Text('${setorDestino.nomUnidade}',
                                style: bodyTextStyle),
                          ]),
                          Row(children: [
                            Text('Departamento: ', style: bodyTextStyleLabel),
                            Text('${setorDestino.nomDepartamento}',
                                style: bodyTextStyle),
                          ]),
                          Row(children: [
                            Text('Setor: ', style: bodyTextStyleLabel),
                            Text('${setorDestino.nomSetor}',
                                style: bodyTextStyle),
                          ]),
                        ]),
                  )
                ]),

            // Padding(padding: const EdgeInsets.all(3)),
            // Row(children: [
            //   Text('Processo: ', style: bodyTextStyleLabel),
            //   Text('13469/2018', style: bodyTextStyle),
            // ]),
            // Padding(padding: const EdgeInsets.all(3)),
            // Row(children: [
            //   Text('Assunto: ', style: bodyTextStyleLabel),
            //   Text('Solicitação', style: bodyTextStyle),
            // ]),
            // Padding(padding: const EdgeInsets.all(3)),
            // Row(children: [
            //   Text('Requerente: ', style: bodyTextStyleLabel),
            //   Text('COTINF - COORDENADORIA DE TECNOLOGIA DA IN',
            //       style: bodyTextStyle),
            // ]),
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
                  <String>['Processo', 'Assunto', 'Requerente', 'Apensos'],
                  ...processos
                      .map((pro) => [
                            pro.codigoProcesso!,
                            pro.nomAssunto!,
                            pro.nomeInteressado!,
                            pro.apensos.isNotEmpty
                                ? pro.apensos.length <= limitApensos
                                    ? pro.apensos
                                        .map((ape) =>
                                            '${ape.codProcesso}/${ape.anoExercicio}')
                                        .join(', ')
                                    : pro.apensos
                                            .sublist(0, limitApensos)
                                            .map((ape) =>
                                                '${ape.codProcesso}/${ape.anoExercicio}')
                                            .join(', ') +
                                        '...'
                                : ''
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    //DateFormat("dd/MM/yyyy 'as' HH:mm").format(now)
                    Text('REMETIDO: ', style: headerTextStyle),
                    Padding(padding: const EdgeInsets.all(5)),
                    Text('Em _____/_____/_____ As _____:_____ h',
                        style: headerTextStyle),
                    Padding(padding: const EdgeInsets.all(5)),
                    // Text('As _____:_____ h ', style: headerTextStyle),
                    Padding(padding: const EdgeInsets.all(5)),
                    Text('Ass. ______________________________ ',
                        style: headerTextStyle),
                    Padding(padding: const EdgeInsets.all(5)),
                    Text('Mat. _______________ ', style: headerTextStyle),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Column(
                  children: [
                    Text('RECEBIDO: ', style: headerTextStyle),
                    Padding(padding: const EdgeInsets.all(5)),
                    Text('Em _____/_____/_____ As _____:_____ h',
                        style: headerTextStyle),
                    Padding(padding: const EdgeInsets.all(5)),
                    //Text('As _____:_____ h ', style: headerTextStyle),
                    Padding(padding: const EdgeInsets.all(5)),
                    Text('Ass. ______________________________ ',
                        style: headerTextStyle),
                    Padding(padding: const EdgeInsets.all(5)),
                    Text('Mat. _______________ ', style: headerTextStyle),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ],
            ),
          ]));

  //save PDF
  final bytes = await pdf.save();
  // if (isDownload) {
  //   FrontUtils.downloadFile(
  //       bytes, 'Guia de Encaminhamento.pdf', 'application/pdf');
  // }
  // if (isPrint) {
  //   FrontUtils.printFileBytes(bytes, 'application/pdf');
  // }
  return bytes;
}
