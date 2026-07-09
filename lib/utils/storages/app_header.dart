import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/storages/base.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveAppHeaderStorage extends BaseObjectStorage<AppHeaderText?> {
  final String _boxName = 'appHeaderStorage';
  static late Box<AppHeaderText?> _box;

  Future<void> ensureInitialized() =>
      StorageInitGuard.ensure(_boxName, init);

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<AppHeaderText?>(_boxName);
    } else {
      _box = Hive.box<AppHeaderText?>(_boxName);
    }
  }

  @override
  Future<void> clear() async {
    await ensureInitialized();
    await _box.clear();
  }

  @override
  void listen(void Function(AppHeaderText?) callback, String key) {
    ensureInitialized().then((_) {
      _box.watch(key: key).listen((event) => callback(event.value));
    });
  }

  @override
  Future<AppHeaderText?> read(String key) async {
    await ensureInitialized();
    return _box.get(key);
  }

  @override
  Future<void> write(String key, AppHeaderText? value) async {
    await ensureInitialized();
    return _box.put(key, value);
  }

  Future<AppHeaderText?> getCurrentHeaderText() async {
    await ensureInitialized();
    return _box.get('current_header_text');
  }

  Future<void> setCurrentHeaderText(AppHeaderText? value) async {
    await ensureInitialized();
    return _box.put('current_header_text', value);
  }
}
