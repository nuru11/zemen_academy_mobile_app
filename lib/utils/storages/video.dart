import 'package:vector_academy/utils/storages/base.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/offline_content_access.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveVideoStorage extends BaseObjectStorage<List<Video>> {
  final String _boxName = 'videoStorage';
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
  void listen(void Function(List<Video> p1) callback, String key) {
    ensureInitialized().then((_) {
      _box.watch(key: key).listen((event) => callback(event.value));
    });
  }

  @override
  Future<List<Video>> read(String key) async {
    await ensureInitialized();
    final videos = _box.get(key) ?? [];
    return videos.cast<Video>();
  }

  @override
  Future<void> write(String key, List<Video> value) async {
    await ensureInitialized();
    return _box.put(key, value);
  }

  Future<void> setVideos(int chapterId, List<Video> videos) async {
    await ensureInitialized();
    _box.put('videos_$chapterId', videos);
  }

  Future<List<Video>> getAllVideos() async {
    await ensureInitialized();
    final videos = _box.get('videos') ?? [];
    final list = videos.cast<Video>();
    final downloadedVideos = await getDownloadedVideos();
    await hydrateVideoListDownloadState(list, downloadedVideos);
    return list;
  }

  Future<void> setAllVideos(List<Video> videos) async {
    await ensureInitialized();
    _box.put('videos', videos);
  }

  Future<List<Video>> getVideos(int chapterId) async {
    final videos = await read('videos_$chapterId');
    final downloadedVideos = await getDownloadedVideos();
    await hydrateVideoListDownloadState(videos, downloadedVideos);
    return videos;
  }

  Future<List<Map<String, dynamic>>> getDownloadedVideos() async {
    await ensureInitialized();
    final videos = _box.get('downloaded_videos') ?? [];
    return videos
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> setDownloadedVideos(List<Map<String, dynamic>> videos) async {
    await ensureInitialized();
    _box.put('downloaded_videos', videos);
  }

  Future<void> addDownloadedVideo(int id, String filePath) async {
    await ensureInitialized();
    final videos = List<dynamic>.from(_box.get('downloaded_videos') ?? []);
    videos.removeWhere((element) => downloadedEntryHasId(element, id));
    videos.add({'id': id, 'file_path': filePath});
    _box.put('downloaded_videos', videos);
  }

  Future<void> removeDownloadedVideo(int id) async {
    await ensureInitialized();
    final videos = List<dynamic>.from(_box.get('downloaded_videos') ?? []);
    videos.removeWhere((element) => downloadedEntryHasId(element, id));
    _box.put('downloaded_videos', videos);
  }

  Future<void> removeAllDownloadedVideos() async {
    await ensureInitialized();
    _box.put('downloaded_videos', []);
  }

  Future<List<Map<String, dynamic>>> getPausedDownloads() async {
    await ensureInitialized();
    final videos = _box.get('paused_video_downloads') ?? [];
    return videos
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> upsertPausedDownload(
    int id,
    double progress,
    String partPath,
  ) async {
    await ensureInitialized();
    final videos = _box.get('paused_video_downloads') ?? [];
    videos.removeWhere((element) => element['id'] == id);
    videos.add({'id': id, 'progress': progress, 'part_path': partPath});
    _box.put('paused_video_downloads', videos);
  }

  Future<void> removePausedDownload(int id) async {
    await ensureInitialized();
    final videos = _box.get('paused_video_downloads') ?? [];
    videos.removeWhere((element) => element['id'] == id);
    _box.put('paused_video_downloads', videos);
  }

  Future<void> removeAllPausedDownloads() async {
    await ensureInitialized();
    _box.put('paused_video_downloads', []);
  }
}
