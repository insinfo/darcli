

import 'dart:typed_data';
import 'package:new_sali_core/new_sali_core.dart';
import 'package:pdf_fork/pdf.dart';
import 'package:pdf_fork/widgets.dart';
import 'package:intl/intl.dart';

Future<Uint8List> geraPDFProcesso(
  Processo processo,
  List<Andamento> andamentosP,
  List<Processo> processosEmApenso,
  List<Processo> emApensoAProcesso,
  String username,
) async {
  final numProcesso = '${processo.codProcesso}/${processo.anoExercicio}';

  final logoUrlSvg = '/assets/images/brasao_editado_1.svg';
  final svgRaw = await SaliCoreUtils.getNetworkTextFile(logoUrlSvg);
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
          ),
        );
      },
      build: (Context context) => <Widget>[
        Header(level: 1, text: 'Processo ${numProcesso}'),
        // Header(level: 2, text: 'Dados do Interessado'),
        Row(children: [
          Text('CGM: ', style: bodyTextStyleLabel),
          Text(processo.numCgm.toString(), style: bodyTextStyle),
          SizedBox(width: 15, height: 15),
          Text('Nome: ', style: bodyTextStyleLabel),
          Text(processo.nomeInteressado ?? '', style: bodyTextStyle),
          SizedBox(width: 15, height: 15),
          Text('Doc: ', style: bodyTextStyleLabel),

          Text(
              processo.documentoInteressado != null
                  ? SaliCoreUtils.hidePartsOfString(
                      processo.documentoInteressado!,
                      visibleCharacters: 5,
                      trail: '*')
                  : '',
              style: bodyTextStyle),
        ]),
        SizedBox(width: 8, height: 8),
        // Header(level: 2, text: 'Dados do Processo'),
        Row(children: [
          Text('Código: ', style: bodyTextStyleLabel),
          Text(processo.codigoProcesso ?? '', style: bodyTextStyle),
          SizedBox(width: 15, height: 15),
          Text('Situação: ', style: bodyTextStyleLabel),
          Text(processo.nomSituacao ?? '', style: bodyTextStyle),
          SizedBox(width: 15, height: 15),
          Text('Incluído em: ', style: bodyTextStyleLabel),
          Text(processo.dataInclusaoFormatada, style: bodyTextStyle),
        ]),
        SizedBox(width: 8, height: 8),
        Row(children: [
          Text('Incluído por: ', style: bodyTextStyleLabel),
          Text(
              '${processo.codUsuario} | ${processo.usuarioQueIncluiu} | ${processo.nomeUsuarioQueIncluiu}',
              style: bodyTextStyle),
        ]),

        SizedBox(width: 8, height: 8),
        Row(children: [
          Text('Classificação: ', style: bodyTextStyleLabel),
          Text(processo.nomClassificacao ?? '', style: bodyTextStyle),
          SizedBox(width: 15, height: 15),
          Text('Assunto: ', style: bodyTextStyleLabel),
          Text(processo.nomAssunto ?? '', style: bodyTextStyle),
        ]),
        SizedBox(width: 8, height: 8),
        Text('Objeto/Observação: ', style: bodyTextStyleLabel),
        SizedBox(width: 5, height: 5),
        Text(processo.observacoes, style: bodyTextStyle),
        SizedBox(width: 8, height: 8),
        Text('Assunto reduzido: ', style: bodyTextStyleLabel),
        SizedBox(width: 5, height: 5),
        Text(processo.resumoAssunto, style: bodyTextStyle),

        //SizedBox(width: 15, height: 15),
        // Text('Organograma último andamento:', style: bodyTextStyle),
        // SizedBox(width: 10, height: 10),
        // Row(children: [
        //   Text('Orgão: ', style: bodyTextStyleLabel),
        //   Text(processo.nomOrgao ?? '', style: bodyTextStyle),
        // ]),
        // SizedBox(width: 8, height: 8),
        // Row(children: [
        //   Text('Unidade: ', style: bodyTextStyleLabel),
        //   Text(processo.nomUnidade ?? '', style: bodyTextStyle),
        // ]),
        // SizedBox(width: 8, height: 8),
        // Row(children: [
        //   Text('Departamento: ', style: bodyTextStyleLabel),
        //   Text(processo.nomDepartamento ?? '', style: bodyTextStyle),
        // ]),
        // SizedBox(width: 8, height: 8),
        // Row(children: [
        //   Text('Setor: ', style: bodyTextStyleLabel),
        //   Text(processo.nomSetor ?? '', style: bodyTextStyle),
        // ]),
        if (processo.codSituacao > 4) ...[
          SizedBox(width: 15, height: 15),
          Text('Texto complementar (Arquivamento): ',
              style: bodyTextStyleLabel),
          SizedBox(width: 5, height: 5),
          Text(processo.textoComplementar ?? '', style: bodyTextStyle),
          SizedBox(width: 8, height: 8),
          Row(children: [
            Text('Arquivado em: ', style: bodyTextStyleLabel),
            Text(processo.dataArquivamentoFormatada, style: bodyTextStyle),
          ]),
        ],

        //processosEmApenso
        if (processosEmApenso.isNotEmpty) ...[
          SizedBox(width: 15, height: 15),
          Text('Processos em Apenso:', style: bodyTextStyle),
          SizedBox(width: 10, height: 10),
          TableHelper.fromTextArray(
              columnWidths: {
                0: FixedColumnWidth(80),
                1: IntrinsicColumnWidth(),
                2: IntrinsicColumnWidth(),
                3: IntrinsicColumnWidth(),
                4: IntrinsicColumnWidth(),
                5: IntrinsicColumnWidth(),
              },
              context: context,
              data: <List<String>>[
                <String>[
                  'Código',
                  'Classificação',
                  'Assunto',
                  'Interessado',
                  'Data apensamento',
                  'Data desapensamento'
                ],
                ...processosEmApenso.map((procA) {
                  return [
                    '${procA.codProcesso}/${procA.anoExercicio}',
                    procA.nomClassificacao ?? '',
                    procA.nomAssunto ?? '',
                    procA.nomeInteressado ?? '',
                    procA.dataApensamentoFormatada,
                    procA.dataDesapensamentoFormatada,
                  ];
                }).toList()
              ]),
        ],

        if (emApensoAProcesso.isNotEmpty) ...[
          SizedBox(width: 15, height: 15),
          Text('Em Apenso a Processos:', style: bodyTextStyle),
          SizedBox(width: 10, height: 10),
          TableHelper.fromTextArray(
              columnWidths: {
                0: FixedColumnWidth(80),
                1: IntrinsicColumnWidth(),
                2: IntrinsicColumnWidth(),
                3: IntrinsicColumnWidth(),
                4: IntrinsicColumnWidth(),
                5: IntrinsicColumnWidth(),
              },
              context: context,
              data: <List<String>>[
                <String>[
                  'Código',
                  'Classificação',
                  'Assunto',
                  'Interessado',
                  'Data apensamento',
                  'Data desapensamento'
                ],
                ...emApensoAProcesso.map((procA) {
                  return [
                    '${procA.codProcesso}/${procA.anoExercicio}',
                    procA.nomClassificacao ?? '',
                    procA.nomAssunto ?? '',
                    procA.nomeInteressado ?? '',
                    procA.dataApensamentoFormatada,
                    procA.dataDesapensamentoFormatada,
                  ];
                }).toList()
              ]),
        ],

        // andamentos
        if (andamentosP.isNotEmpty) ...[
          SizedBox(width: 15, height: 15),
          Text('Trâmites do Processo:', style: bodyTextStyle),
          SizedBox(width: 10, height: 10),
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
                ...andamentosP.map((anda) {
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
