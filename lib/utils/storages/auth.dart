import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/storages/base.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveAuthStorage extends BaseObjectStorage<AuthToken> {
  final String _boxName = 'authTokenStorage';
  static late Box<AuthToken> _box;

  Future<void> ensureInitialized() =>
      StorageInitGuard.ensure(_boxName, init);

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<AuthToken>(_boxName);
    } else {
      _box = Hive.box<AuthToken>(_boxName);
    }
  }

  @override
  void listen(void Function(AuthToken) callback, String key) {
    ensureInitialized().then((_) {
      _box.watch(key: key).listen((event) => callback(event.value));
    });
  }

  @override
  Future<void> clear() async {
    await ensureInitialized();
    await _box.clear();
  }

  @override
  Future<AuthToken?> read(String key) async {
    await ensureInitialized();
    return _box.get(key);
  }

  @override
  Future<void> write(String key, AuthToken value) async {
    await ensureInitialized();
    return _box.put(key, value);
  }

  Future<AuthToken?> getAuthToken() async {
    await ensureInitialized();
    return _box.get('authToken');
  }

  Future<void> setAuthToken(AuthToken authToken) async {
    await ensureInitialized();
    return _box.put('authToken', authToken);
  }
}

class HiveUserStorage extends BaseObjectStorage<User?> {
  final String _boxName = 'userStorage';
  static late Box<User?> _box;

  Future<void> ensureInitialized() =>
      StorageInitGuard.ensure(_boxName, init);

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<User?>(_boxName);
    } else {
      _box = Hive.box<User?>(_boxName);
    }
  }

  @override
  Future<void> clear() async {
    await ensureInitialized();
    await _box.clear();
  }

  @override
  void listen(void Function(User? p1) callback, String key) {
    ensureInitialized().then((_) {
      _box.watch(key: key).listen((event) => callback(event.value));
    });
  }

  @override
  Future<User?> read(String key) async {
    await ensureInitialized();
    return _box.get(key);
  }

  @override
  Future<void> write(String key, User? value) async {
    await ensureInitialized();
    return _box.put(key, value);
  }

  Future<User?> getUser() async {
    await ensureInitialized();
    return _box.get('user');
  }

  Future<void> setUser(User user) async {
    await ensureInitialized();
    return _box.put('user', user);
  }
}
