import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:new_sali_backend/new_sali_backend.dart';
import 'package:new_sali_core/new_sali_core.dart';
import "package:path/path.dart" as p;

/// Armazena dados de cache no Browser LocalStorage
/// funciona Map<String, dynamic>
class DiskMapCache {
  Duration cacheValidDuration = Duration(minutes: 30);
  String cacheKey;
  String cacheDirPath;
  String cacheName;

  static Future<void> clearByName(String cacheName, String cacheDPath) async {
   // print( 'DiskMapCache@clearByName cacheName: $cacheName | cacheDPath: $cacheDPath');
    final dir = Directory(cacheDPath);

    //var completer = Completer<void>();
    await dir.list(recursive: false).forEach((file) async {
      if (file is File) {
        final name = p.basename(file.path);
        final extension = p.extension(name);       
        if (name.startsWith(cacheName + '_') && extension == '.json') {
          await file.delete();
          print('cache $cacheName removido');
        }
      }
    });
  }

  DiskMapCache(this.cacheKey, this.cacheDirPath,
      {this.cacheName = '', this.cacheValidDuration = const Duration(days: 5)});

  /// is update the cache
  Future<bool> isShouldRefresh() async {
    var lastFetchTime = await _getLastFetchTime();
    return (null == lastFetchTime ||
        lastFetchTime.isBefore(DateTime.now().subtract(cacheValidDuration)));
  }

  Future<Map<String, dynamic>> getItem() async {
    var items = await _readFromDiskRecords();
    return items;
  }

  Future<void> putItem(Map<String, dynamic> object) async {
    await _writeToDiskRecords(object);
  }

  Future<String> get _cacheFilePath async {
    var fileName = BackendUtils.stringToMd5(cacheKey) + '.json';
    if (cacheName.isNotEmpty) {
      fileName = cacheName + '_' + fileName;
    }
    return p.join(cacheDirPath, fileName);
  }

  Future<void> _writeToDiskRecords(Object? obj) async {
    if (obj != null) {
      String json =
          jsonEncode(obj, toEncodable: SaliCoreUtils.customJsonEncode);
      final filePath = await _cacheFilePath;
      var file = File(filePath);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      file.setLastModifiedSync(DateTime.now());
      // print('DiskCache@_writeToDiskRecords records ');
      await file.writeAsString(json, flush: true);
    } else {
      throw Exception('Tentando gravar nulo no cache');
    }
  }

  Future<Map<String, dynamic>> _readFromDiskRecords() async {
    final filePath = await _cacheFilePath;
    var file = File(filePath);
    if (!(await file.exists())) {
      throw Exception('arquivo de cache não existe');
    }
    // Read the file
    var contents = await file.readAsString();
    if (contents == '') {
      throw Exception('arquivo de cache esta vazio ou corronpido');
    }

    var obj = jsonDecode(contents);
    return (obj as Map<String, dynamic>);
  }

  Future<DateTime?> _getLastFetchTime() async {
    try {
      final filePath = await _cacheFilePath;
      var file = File(filePath);
      if (!file.existsSync()) {
        return null;
      }
      return file.lastModifiedSync();
    } catch (e) {
      print("DiskCacheMap@getLastFetchTime $e");
      return null;
    }
  }
}
