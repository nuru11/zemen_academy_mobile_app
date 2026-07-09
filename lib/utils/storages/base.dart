abstract class BaseObjectStorage<T> {
  Future<void> init();
  Future<void> clear();
  Future<void> write(String key, T value);
  Future<T?> read(String key);

  void listen(void Function(T) callback, String key);
}

class StorageInitGuard {
  StorageInitGuard._();

  static final Map<String, Future<void>> _futures = {};

  static Future<void> ensure(String key, Future<void> Function() init) {
    return _futures.putIfAbsent(key, init);
  }
}
