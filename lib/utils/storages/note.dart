import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/storages/base.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveNoteStorage extends BaseObjectStorage<List<Note>> {
  final String _boxName = 'noteStorage';
  static late Box<List<dynamic>> _box;

  Future<void> ensureInitialized() =>
      StorageInitGuard.ensure(_boxName, init);

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<List<dynamic>>(_boxName);
    } else {
      _box = Hive.box<List<dynamic>>(_boxName);
    }
  }

  @override
  Future<void> clear() async {
    await ensureInitialized();
    await _box.clear();
  }

  @override
  void listen(void Function(List<Note>) callback, String key) {
    ensureInitialized().then((_) {
      _box.watch(key: key).listen((event) => callback(event.value));
    });
  }

  @override
  Future<List<Note>?> read(String key) async {
    await ensureInitialized();
    final value = _box.get(key) ?? [];
    return value.cast<Note>();
  }

  @override
  Future<void> write(String key, List<Note> value) async {
    await ensureInitialized();
    return _box.put(key, value);
  }

  Future<void> setNotes(int chapterId, List<Note> notes) async {
    await ensureInitialized();
    return _box.put('notes_$chapterId', notes);
  }

  Future<void> setAllNotes(List<Note> notes) async {
    await ensureInitialized();
    return _box.put('notes', notes);
  }

  Future<List<Note>> getNotes(int chapterId) async {
    await ensureInitialized();
    final value = _box.get('notes_$chapterId') ?? [];

    final downloadedNotes = await getDownloadedNotes();
    for (var note in value) {
      final downloadedNote = downloadedNotes.firstWhere(
        (element) => element['id'] == note.id,
        orElse: () => {},
      );
      note.filePath = downloadedNote['file_path'];
      if (note.filePath != null) {
        note.isDownloaded = true;
      }
    }

    return value.cast<Note>();
  }

  Future<List<Note>> getAllNotes() async {
    await ensureInitialized();
    final value = _box.get('notes') ?? [];
    final downloadedNotes = await getDownloadedNotes();
    for (var note in value) {
      final downloadedNote = downloadedNotes.firstWhere(
        (element) => element['id'] == note.id,
        orElse: () => {},
      );
      note.filePath = downloadedNote['file_path'];
      if (note.filePath != null) {
        note.isDownloaded = true;
      }
    }
    return value.cast<Note>();
  }

  Future<void> addDownloadedNote(int id, String filePath) async {
    await ensureInitialized();
    final notes = _box.get('downloaded_notes') ?? [];
    notes.add({'id': id, 'file_path': filePath});
    _box.put('downloaded_notes', notes);
  }

  Future<List<Map<String, dynamic>>> getDownloadedNotes() async {
    await ensureInitialized();
    final value = _box.get('downloaded_notes') ?? [];
    return value
        .cast<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> setDownloadedNotes(List<Map<String, dynamic>> notes) async {
    await ensureInitialized();
    _box.put('downloaded_notes', notes);
  }

  Future<void> removeDownloadedNote(int id) async {
    await ensureInitialized();
    final notes = _box.get('downloaded_notes') ?? [];
    notes.removeWhere((element) => element['id'] == id);
    _box.put('downloaded_notes', notes);
  }

  Future<void> removeAllDownloadedNotes() async {
    await ensureInitialized();
    _box.put('downloaded_notes', []);
  }
}
