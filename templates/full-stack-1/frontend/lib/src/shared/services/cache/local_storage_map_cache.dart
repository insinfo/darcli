import 'dart:async';
import 'dart:convert';
import 'package:new_sali_core/new_sali_core.dart';
import 'dart:html';

/// Armazena dados de cache no Browser LocalStorage
/// funciona List<Map<String, dynamic>>
class LocalStorageMapCache extends CacheBase<List<Map<String, dynamic>>> {
  Duration cacheValidDuration = Duration(minutes: 30);
  String cacheFileName;

  LocalStorageMapCache(this.cacheFileName,
      {this.cacheValidDuration = const Duration(minutes: 30)});

  /// is update the cache
  Future<bool> isShouldRefresh() async {
    var lastFetchTime = await _getLastFetchTime();
    return (null == lastFetchTime ||
        lastFetchTime.isBefore(DateTime.now().subtract(cacheValidDuration)));
  }

  @override
  Future<List<Map<String, dynamic>>> getItem() async {
    var items = await _readFromDiskRecords();

    return items;
  }

  @override
  Future<void> putItem(List<Map<String, dynamic>> object) async {
    await _writeToDiskRecords(object);
  }

  Future<void> _writeToDiskRecords(Object? obj) async {
    if (obj != null) {
      String json =
          jsonEncode(obj, toEncodable: SaliCoreUtils.customJsonEncode);
      window.localStorage[cacheFileName] = json;
      window.localStorage[cacheFileName + '.time'] =
          jsonEncode({'lastFetchTime': DateTime.now().toIso8601String()});
    } else {
      throw Exception('Tentando gravar nulo no cache');
    }
  }

  Future<List<Map<String, dynamic>>> _readFromDiskRecords() async {
    var contents = window.localStorage[cacheFileName];

    if (contents == '' || contents == null) {
      throw Exception('arquivo de cache esta vazio ou corronpido');
    }
    var obj = jsonDecode(contents);
    return (obj as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<DateTime?> _getLastFetchTime() async {
    try {
      final content = await window.localStorage[cacheFileName + '.time'];
      if (content == null || content == '') {
        return null;
      }
      var map = jsonDecode(content);
      if (map == null) {
        return null;
      }
      return DateTime.parse(map['lastFetchTime']);
    } catch (e) {
      print("LocalStorageMapCache@getLastFetchTime $e");
      return null;
    }
  }
}
