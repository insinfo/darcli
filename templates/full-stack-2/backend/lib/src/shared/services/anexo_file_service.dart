import 'dart:io';
import 'package:esic_backend/src/shared/app_config.dart';
import 'package:esic_core/esic_core.dart';

import 'package:uuid/uuid.dart';

class AnexoFileService {
  DateTime? currentDate;
  AnexoFileService({this.currentDate}) {}
  Future<String> create(
    Anexo file, {
    String? baseDirectory,
    bool randFileName = true,
    bool criaDiretoriaBaseadoNoAnoMesAndRetorna = true,
  }) async {
    currentDate = currentDate == null ? DateTime.now() : currentDate;

    baseDirectory =
        baseDirectory == null ? AppConfig.inst().storageDir : baseDirectory;

    final filename = randFileName
        ? '${const Uuid().v4()}.${file.nome.split(".").last}'
        : file.nome;
    var directory = baseDirectory;

    final directoryAnoMes = '${currentDate!.year}/${DateTime.now().month}';
    if (criaDiretoriaBaseadoNoAnoMesAndRetorna) {
      directory = '$baseDirectory/$directoryAnoMes';
    }

    if (!Directory(directory).existsSync()) {
      // Create a new directory, recursively creating non-existent directories.
      Directory(directory).createSync(recursive: true);
    }

    final filePath = '${directory}/${filename}';
    

    if (file.bytes.isEmpty) {
      throw Exception('Não ha bytes em Anexo');
    }

    await File(filePath).writeAsBytes(file.bytes, flush: true);

    

    if (!File(filePath).existsSync()) {
      throw Exception('Falha ao criar o arquivo');
    }
    if (criaDiretoriaBaseadoNoAnoMesAndRetorna) {
      return '$directoryAnoMes/$filename';
    }

    return filename;
  }

  Future<void> deleteIfExist(
    String filePath, {
    bool onBaseDir = true,
    String? baseDirectory,
  }) async {
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
