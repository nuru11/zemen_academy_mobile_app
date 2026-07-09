import 'package:vector_academy/services/api/api.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/api/exceptions.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class NoteService {
  final ApiClient apiClient = ApiClient();

  Future<List<Note>> getNotes(String deviceId, {required int chapterId}) async {
    final response = await apiClient.get(
      '/app/notes?chapter=$chapterId&device=$deviceId',
      authenticated: true,
    );
    return (response.data as List).map((e) => Note.fromJson(e)).toList();
  }

  Future<List<Note>> getAllNotes(String deviceId, {int? gradeId}) async {
    final queryParams = <String, dynamic>{};
    if (gradeId != null) {
      queryParams['grade'] = gradeId;
    }
    final response = await apiClient.get(
      '/app/notes?device=$deviceId',
      authenticated: true,
      queryParameters: queryParams,
    );
    if (response.statusCode != 200) {
      throw ApiException('Failed to get all notes');
    }
    return (response.data as List).map((e) => Note.fromJson(e)).toList();
  }

  Future<void> downloadNote(
    int noteId, {
    required String deviceId,
    required Function(String?, double) onData,
    required Function(String) onDone,
    required Function(String) onError,
  }) async {
    final response = await apiClient.get(
      '/app/notes/$noteId?device=$deviceId',
      authenticated: true,
    );
    if (response.statusCode != 200) {
      throw ApiException('Failed to download note');
    }

    final url = response.data['file'];

    FileDownloader.downloadFile(
      url: url,
      downloadDestination: DownloadDestinations.appFiles,
      onProgress: onData,
      onDownloadCompleted: onDone,
      onDownloadError: onError,
    );
  }
}
