import 'dart:io';
//import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class DocToPdfService {

  /// convert docx to PDF
  /// [docxFileBytes] bytes of DOCX file
  /// `Return` bytes of PDF file
  Future<List<int>> converteAsBytes(List<int> docxFileBytes,
      {String fileExtencion = 'docx'}) async {
    final uid = Uuid().v4();
    final tmpDir = Directory.systemTemp.path;
    final fileToConverte = '$uid.$fileExtencion';
    //final tmpDocFile = tmpDir.replaceAll('\\', '/') + '/' + fileToConverte;
    final tmpDocFile = path.join(tmpDir, fileToConverte);
    // cria arquivo docx temporario
    await File(tmpDocFile).writeAsBytes(docxFileBytes, flush: true);

    final result = await Process.run(
      Platform.isWindows ? 'soffice.exe' : 'soffice',
      ['--headless', '--convert-to', 'pdf', '--outdir', '$tmpDir', tmpDocFile],
      runInShell: false,
      //workingDirectory: tmpDir,
    );

    final tmpPdfFile = path.join(tmpDir, '$uid.pdf');

    final bytes = await File(tmpPdfFile).readAsBytes();
    File(tmpDocFile).delete();
    File(tmpPdfFile).delete();
    // stdout.write(result.stdout);
    // stderr.write(result.stderr);
    print('DocToPdfService@converteAsBytes result: ${result.stdout}');
    //result convert C:\MyDartProjects\new_sali\backend\file-sample_100kB.docx -> C:\MyDartProjects\new_sali\backend\file-sample_100kB.pdf using filter : writer_pdf_Export
    return bytes;
  }
}
