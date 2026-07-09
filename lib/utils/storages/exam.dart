import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/utils.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'base.dart';

class HiveExamStorage extends BaseObjectStorage<List<Exam>> {
  final String _boxName = 'examStorage';
  static late Box<dynamic> _box;

  Future<void> ensureInitialized() =>
      StorageInitGuard.ensure(_boxName, init);

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<dynamic>(_boxName);
    } else {
      _box = Hive.box<dynamic>(_boxName);
    }
  }

  @override
  void listen(void Function(List<Exam>) callback, String key) {
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
  Future<List<Exam>> read(String key) async {
    await ensureInitialized();
    final value = _box.get(key) ?? [];
    return value.cast<Exam>();
  }

  @override
  Future<void> write(String key, List<Exam> value) async {
    await ensureInitialized();
    return _box.put(key, value);
  }

  Future<List<Exam>> getExams() async {
    await ensureInitialized();
    final value = _box.get('exams') ?? [];
    for (var exam in value) {
      exam.questions = await getQuestions(exam.id);
      if (exam.questions.isNotEmpty) {
        exam.isDownloaded = true;
      }
      _hydrateExamState(exam);
    }

    return value.cast<Exam>();
  }

  Future<void> setExams(List<Exam> exams) async {
    await ensureInitialized();
    return _box.put('exams', exams);
  }

  Future<void> setQuizzes(int chapterId, List<Exam> quizzes) async {
    await ensureInitialized();
    logger.i('Setting quizzes for chapter $chapterId');
    return _box.put('quizzes_$chapterId', quizzes);
  }

  Future<List<Exam>> getQuizzes(int chapterId) async {
    await ensureInitialized();
    final value = _box.get('quizzes_$chapterId') ?? [];
    for (var quiz in value) {
      quiz.questions = await getQuestions(quiz.id);
      if (quiz.questions.isNotEmpty) {
        quiz.isDownloaded = true;
      }
      _hydrateExamState(quiz);
    }
    return value.cast<Exam>();
  }

  Future<List<Question>> getQuestions(int examId) async {
    await ensureInitialized();
    final value = _box.get('questions_$examId') ?? [];
    for (var question in value) {
      question.imagePath = await getQuestionImages(question.id);
    }
    return value.cast<Question>();
  }

  Future<void> setQuestions(int examId, List<Question> questions) async {
    await ensureInitialized();
    return _box.put('questions_$examId', questions);
  }

  Future<String?> getQuestionImages(int questionId) async {
    await ensureInitialized();
    final value = _box.get('question_images_$questionId') ?? [];

    return value.cast<String?>().firstWhere((e) => true, orElse: () => null);
  }

  Future<void> setQuestionImages(int questionId, String image) async {
    await ensureInitialized();
    return _box.put('question_images_$questionId', [image]);
  }

  Future<void> removeDownloadedExam(int id) async {
    await ensureInitialized();
    final exams = _box.get('downloaded_exams') ?? [];
    exams.removeWhere((element) => element['id'] == id);
    _box.put('downloaded_exams', exams);
  }

  Future<void> removeAllDownloadedExams() async {
    await ensureInitialized();
    _box.put('downloaded_exams', []);
  }

  /// Deletes all data for a specific exam including questions and question images
  Future<void> deleteExamData(int examId) async {
    await ensureInitialized();
    // Get questions first to find all question IDs for image deletion
    final questionsValue = _box.get('questions_$examId');
    if (questionsValue != null && questionsValue is List) {
      try {
        final questions = questionsValue.cast<Question>();
        for (var question in questions) {
          // Delete question images
          await _box.delete('question_images_${question.id}');
        }
      } catch (e) {
        // If casting fails, questions might be in a different format
        // Continue to delete the questions key anyway
        logger.w('Error casting questions for exam $examId: $e');
      }
    }
    
    // Delete questions key
    await _box.delete('questions_$examId');
  }

  /// Deletes all exam data for all exams (used when clearing all downloads)
  Future<void> deleteAllExamData() async {
    final exams = await getExams();
    for (var exam in exams) {
      await deleteExamData(exam.id);
    }
  }

  // --- Added helpers to persist per-exam state on the same box ---

  Future<void> markCompleted(int examId) async {
    await ensureInitialized();
    await _box.put(_keyCompleted(examId), true);
  }

  Future<void> clearCompleted(int examId) async {
    await ensureInitialized();
    await _box.delete(_keyCompleted(examId));
  }

  Future<bool> isCompleted(int examId) async {
    await ensureInitialized();
    final v = _box.get(_keyCompleted(examId));
    return (v is bool ? v : false);
  }

  Future<Set<int>> completedExamIds() async {
    await ensureInitialized();
    return _box.keys
        .whereType<String>()
        .where((k) => k.startsWith('completed_'))
        .map((k) => int.tryParse(k.split('_').last) ?? 0)
        .where((id) => id != 0)
        .toSet();
  }

  Future<Map<String, dynamic>?> getProgress(int examId, String mode) async {
    await ensureInitialized();
    final v = _box.get(_keyProgress(examId, mode));
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  Future<void> saveProgress(
    int examId, {
    required int currentIndex,
    required List<int?> answers,
    required int timeRemaining,
    required String mode,
  }) async {
    await ensureInitialized();
    await _box.put(_keyProgress(examId, mode), {
      'current_question_index': currentIndex,
      'selected_answers': answers,
      'remaining_time': timeRemaining,
      'mode': mode,
    });
  }

  Future<void> clearProgress(int examId, String mode) async {
    await ensureInitialized();
    await _box.delete(_keyProgress(examId, mode));
  }

  String _keyCompleted(int examId) => 'completed_$examId';
  String _keyProgress(int examId, String mode) => 'progress_${examId}_$mode';

  void _hydrateExamState(Exam exam) {
    // Move persisted flags/progress into the in-memory object fields for convenience
    final completed = _box.get(_keyCompleted(exam.id));
    exam.isCompleted = completed is bool ? completed : false;

    // If any progress for any mode exists, pick the latest by inspecting keys. This avoids needing to know mode here.
    final keys = _box.keys.whereType<String>().where(
      (k) => k.startsWith('progress_${exam.id}_'),
    );
    final lastKey = keys.isNotEmpty ? keys.last : null;
    if (lastKey != null) {
      final map = _box.get(lastKey);
      if (map is Map) {
        exam.progress = ExamProgress.fromMap(map);
      }
    }
  }
}
