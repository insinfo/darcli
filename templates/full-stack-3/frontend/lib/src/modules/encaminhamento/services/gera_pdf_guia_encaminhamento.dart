import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sibem_frontend/sibem_frontend.dart';

Future<Uint8List> geraPDFGuiaEncaminhamento(
    Encaminhamento encaminhamento) async {
  
  final urlLogoPmroSvg = '/assets/images/brasao_editado_1.svg';
  final svgLogoPmroText = await FrontUtils.getNetworkTextFile(urlLogoPmroSvg);
  final svgImageLogoPmro = SvgImage(svg: svgLogoPmroText);
  final pdf = Document();
  final now = DateTime.now();

  if (encaminhamento.empregador == null) {
    throw Exception('empregador não pode ser nulo');
  }
  if (encaminhamento.candidato == null) {
    throw Exception('candidato não pode ser nulo');
  }
  if (encaminhamento.vaga == null) {
    throw Exception('vaga não pode ser nulo');
  }

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
                Text('Estado do Rio de Janeiro', style: headerTextStyle),
                Text('Municipio de city', style: headerTextStyle),
                // Text('office Municipal',
                //     style: headerTextStyle),
                Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                //Text('Id Usuário que emitiu: $idUsuario', style: headerTextStyle),
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
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'UNIDADE BANCO DE EMPREGOS DE city',
              style: TextStyle(
                  fontSize: 13,
                  color: PdfColor.fromInt(0xff000000),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(10)),
        Container(
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 2))),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            alignment: Alignment.center,
            child: Text('E N C A M I N H A M E N T O'),
          ),
        ),
        Container(
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 2))),
        ),
        //
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Container(
            alignment: Alignment.topRight,
            child: Text(
              encaminhamento.vaga!.formaEncaminhamento == 'Email' ||
                      encaminhamento.vaga!.formaEncaminhamento == 'WhatsApp'
                  ? '''ENVIAR ${encaminhamento.vaga!.formaEncaminhamento.toUpperCase()}, COM CURRÍCULO E CARTA DE ENCAMINHAMENTO PARA:
${encaminhamento.vaga!.complementoFormaEncaminhamento.toUpperCase()}
AGUARDAR A EMPRESA ENTRAR EM CONTATO, CASO SELECIONADO PARA ENTREVISTA.'''
                  : ''' COMPARECER COM CARTA DE ENCAMINHAMENTO E CURRÍCULO NO ENDEREÇO: 
${encaminhamento.vaga!.complementoFormaEncaminhamento.toUpperCase()} ''',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                color: PdfColor.fromInt(0xff000000),
                fontWeight: FontWeight.normal,
                lineSpacing: 4,
              ),
            ),
          ),
        ),
        //
        Padding(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: Container(
            alignment: Alignment.topLeft,
            child: Text(
              '''
 city, ${DateFormat('dd/MM/yyyy').format(now)}
 A(o) ${encaminhamento.vaga!.confidencialidadeEmpresa == true ? encaminhamento.vaga!.contatoEncaminhamento : encaminhamento.empregador!.nome}
 Prezado(a) Senhor(a):
 Encaminhamos o Sr(a) ${encaminhamento.candidato!.nome},
 para entrevista e possível contratação à vaga de ${encaminhamento.vaga!.cargoNome}.
 Solicito ao Sr(a) que nos dê o retorno da situação do candidato.
''',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                color: PdfColor.fromInt(0xff000000),
                fontWeight: FontWeight.normal,
                lineSpacing: 10,
              ),
            ),
          ),
        ),
        // ASSINATURA
        Padding(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'Atensiosamente,',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
                color: PdfColor.fromInt(0xff000000),
                fontWeight: FontWeight.normal,
                lineSpacing: 10,
              ),
            ),
          ),
        ),
      ],
      footer: (Context context) {
        return Container(
            alignment: Alignment.center,
            child: Column(children: [
              
            ]));
        // return Container(
        //     alignment: Alignment.centerRight,
        //     margin: EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
        //     child: Text('Página ${context.pageNumber} de ${context.pagesCount}',
        //         style: Theme.of(context)
        //             .defaultTextStyle
        //             .copyWith(color: PdfColors.grey)));
      },
    ),
  );

  //save PDF
  final bytes = await pdf.save();

  return bytes;
}
