import 'dart:io';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class AnexoFileService {
  /// data que sera usada para criar o diretorio do arquivo ano/mes
  DateTime? currentDate;
  AnexoFileService({this.currentDate}) {}
  Future<String> create(List<int> bytes, String originalFilename,
      {String? baseDirectory,
      bool randFileName = true,
      bool criaDirAnoMesAndRetorna = true}) async {
    currentDate = currentDate == null ? DateTime.now() : currentDate;
    //print("storage_dir ${appConfig.storageDir}");
    baseDirectory =
        baseDirectory == null ? appConfig.storageDir : baseDirectory;

    final uid = Uuid().v4();

    final filename = randFileName
        ? '${uid}.${originalFilename.split('.').last}'
        : originalFilename;

    var directory = baseDirectory;

    final directoryAnoMes = path.join(currentDate!.year.toString(),
        currentDate!.month.toString().padLeft(2, '0'));

    if (criaDirAnoMesAndRetorna) {
      directory = path.join(baseDirectory, directoryAnoMes);
    }

    if (!Directory(directory).existsSync()) {
      // Create a new directory, recursively creating non-existent directories.
      Directory(directory).createSync(recursive: true);
    }

    final filePath = path.join(directory, filename);

    // final Stream<List<int>> content = file.fileDataStrem!;
    // final IOSink sink = File(filePath).openWrite();
    // await for (var item in content) {
    //   sink.add(item);
    // }
    // await sink.flush();
    // await sink.close();
    final outFile = File(filePath);
    await outFile.writeAsBytes(bytes, flush: true);
    //print('FileService@create filePath $filePath');

    if (!outFile.existsSync()) {
      throw Exception('Falha ao criar o arquivo');
    }
    if (criaDirAnoMesAndRetorna) {
      return '${directoryAnoMes.replaceAll(r'\', r'/')}/$filename';
    }

    return filename;
  }

  Future<void> deleteIfExist(String filePath,
      {bool onBaseDir = true, String? baseDirectory}) async {
    try {
      var fp = filePath;
      if (onBaseDir) {
        var baseDir =
            baseDirectory == null ? AppConfig.inst().storageDir : baseDirectory;
        fp = '$baseDir/$filePath';
      }
      final myFile = File(fp);
      await myFile.delete();
    } catch (e) {
      print('FileService@deleteIfExist $e');
    }
  }
}
