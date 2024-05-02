import 'dart:async';

abstract class CacheBase<T> {
  Future<T> getItem();

  Future<void> putItem(T object);

  clear() {
    throw UnimplementedError();
  }

  /// verifica se é nessessario atualizar o cache
  Future<bool> isShouldRefresh();
}
