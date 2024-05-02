
/*
class MemCache<T> extends CacheBase<T> {
  Duration cacheValidDuration = Duration(minutes: 30);

  MemCache({this.cacheValidDuration = const Duration(minutes: 30)});

  DateTime lastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);
  List<T> allRecords = <T>[];

  //se deve atualizar o cache buscando dados da API
  Future<bool> isShouldRefresh() async {
    return (allRecords.isEmpty ||
        lastFetchTime.isBefore(DateTime.now().subtract(cacheValidDuration)));
  }

  @override
  Future<List<T>> getAll() {
    return Future.value(allRecords);
  }

  @override
  Future<void> putAll(List<T> objects) async {
    allRecords.clear();
    allRecords.addAll(objects);
    lastFetchTime = DateTime.now();
  }

  @override
  Future<void> putAllAsync(Future<List<T>> objects) async {
    var items = await objects;
    await putAll(items);
  }
}
*/