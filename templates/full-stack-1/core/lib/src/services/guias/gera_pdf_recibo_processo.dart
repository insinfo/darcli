import 'dart:typed_data';
import 'package:new_sali_core/new_sali_core.dart';

import 'package:pdf_fork/pdf.dart';
import 'package:pdf_fork/widgets.dart';
import 'package:intl/intl.dart';

/// capa de processo
Future<Uint8List> geraPDFReciboProcesso(Processo processo, String username,
    String nomeSetorDestino, String? nomeSetorOrigem) async {
  

  final urlLogoPmroSvg = '/assets/images/brasao_editado_1.svg';
  final svgLogoPmroText =
      await SaliCoreUtils.getNetworkTextFile(urlLogoPmroSvg);
  final svgImageLogoPmro = SvgImage(svg: svgLogoPmroText);
  final pdf = Document();
  final now = DateTime.now();
  //cria codigo de barras
  final barCode = Barcode.code128();
  final svgImageBarCode = SvgImage(
      svg: barCode.toSvg('${processo.codProcesso}/${processo.anoExercicio}',
          drawText: false));

  // Create a DataMatrix barcode
  final qrCode = Barcode.qrCode();
  // Generate a SVG with string
  final svgImageQrCode = SvgImage(
      svg: qrCode.toSvg(
          'site.com/${processo.anoExercicio}/${processo.codProcesso}',
          width: 100,
          height: 100));

  var headerTextStyle =
      TextStyle(fontSize: 10, color: PdfColor.fromInt(0xff2c3e50));

  var bodyTextStyle = TextStyle(
      fontSize: 11,
      color: PdfColor.fromInt(0xff000000),
      fontWeight: FontWeight.bold);

  var bodyTextStyleLabel =
      TextStyle(fontSize: 11, color: PdfColor.fromInt(0xff000000));
  var mainAxisSize = MainAxisSize.max;
  pdf.addPage(
    MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginTop: 1.0 * PdfPageFormat.cm,
        marginLeft: 2.0 * PdfPageFormat.cm,
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
            
                Text('Usuário: $username', style: headerTextStyle),
                //Text('Processo número: ${processo.numeroProcessoFormatado}', style: headerTextStyle),
                Text(
                    '''Emissão: ${DateFormat("dd/MM/yyyy 'às' HH:mm").format(now)}   |   Página: ${context.pageNumber} de ${context.pagesCount}''',
                    style: headerTextStyle),
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
      build: (Context context) => <Widget>[
        Header(level: 1, text: 'Protocolo de Processo'),
        ListView(
            spacing: 2, //290
            padding: const EdgeInsets.fromLTRB(130, 240, 0, 0),
            children: [
              Row(mainAxisSize: mainAxisSize, children: [
                Text('Processo: ',
                    style: TextStyle(
                        fontSize: 12, color: PdfColor.fromInt(0xff000000))),
                Text(processo.numeroProcessoFormatado, style: bodyTextStyle),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                Text('Data da inclusão: ', style: bodyTextStyleLabel),
                Text('${processo.dataHoraInclusaoFormatada}',
                    style: bodyTextStyle),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                Text('Assunto: ', style: bodyTextStyleLabel),
                Text(processo.nomAssunto ?? '', style: bodyTextStyle),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                Text('Requerente: ', style: bodyTextStyleLabel),
                // Text(processo.nomeInteressado ?? '', style: bodyTextStyle),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                //Text('Requerente: ', style: bodyTextStyleLabel),
                Text(processo.nomeInteressado ?? '', style: bodyTextStyle),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                Text('CGM: ', style: bodyTextStyleLabel),
                Text(processo.numCgm.toString(), style: bodyTextStyle),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                Text('Destino: ', style: bodyTextStyleLabel),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                Text(nomeSetorDestino, style: bodyTextStyle),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                    child: SizedBox(
                      height: 25,
                      width: 150,
                      child: svgImageBarCode,
                    )),
              ]),
              Row(mainAxisSize: mainAxisSize, children: [
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: svgImageQrCode,
                    )),
              ]),
            ]),

        //INFORMATIVO:
        Padding(padding: EdgeInsets.only(top: 40), child: Text('INFORMATIVO:')),
        Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
                '''Consulte seu processo pelos telefones  \r\n
ou pelo endereço site \r\n
ou  - Serviços - Andamento de Processos''',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ))),
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
  
  return bytes;
}
