import 'dart:async';

import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/api/api.dart';
import 'package:vector_academy/utils/storages/storages.dart';
import 'package:vector_academy/utils/storages/app_header.dart';
import 'package:vector_academy/utils/utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:vector_academy/services/auth.dart';
import 'package:vector_academy/services/core.dart';
import 'package:vector_academy/services/api/grades.dart';
import 'package:vector_academy/services/notification_service.dart'
    as local_notif;

void _safeRegister<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter<T>(adapter);
  }
}

void registerHiveAdapters() {
  _safeRegister(GradeTypeAdapter());
  _safeRegister(AuthTokenTypeAdapter());
  _safeRegister(UserTypeAdapter());
  _safeRegister(ChapterTypeAdapter());
  _safeRegister(ExamTypeAdapter());
  _safeRegister(NoteTypeAdapter());
  _safeRegister(SubjectTypeAdapter());
  _safeRegister(ChoiceTypeAdapter());
  _safeRegister(VideoTypeAdapter());
  _safeRegister(QuestionTypeAdapter());
  _safeRegister(AppHeaderTextTypeAdapter());
  _safeRegister(StudyPlanTypeAdapter());
  _safeRegister(NotificationTypeAdapter());
}

Future<void> initialize() async {
  await Hive.initFlutter();
  registerHiveAdapters();
  await HiveAuthStorage().ensureInitialized();
  await HiveUserStorage().ensureInitialized();
  await ConfigPreference.init();

  Get.put(AuthService());
  Get.put(CoreService());
  Get.put(GradeService());
  Get.put(local_notif.LocalNotificationService());

  final authToken = await HiveAuthStorage().getAuthToken();
  BaseApiClient.setTokens(authToken?.access ?? '', authToken?.refresh ?? '');

  logger.i('Initializing the application');
}

Future<void> warmUpDeferredStorages() async {
  await Future.wait([
    HiveChaptersStorage().ensureInitialized(),
    HiveSubjectsStorage().ensureInitialized(),
    HiveExamStorage().ensureInitialized(),
    HiveQuizzesStorage().ensureInitialized(),
    HiveNoteStorage().ensureInitialized(),
    HiveVideoStorage().ensureInitialized(),
    HiveStudyPlanStorage().ensureInitialized(),
    HiveAppHeaderStorage().ensureInitialized(),
    HiveNewsStorage().ensureInitialized(),
    HiveLeaderboardCacheStorage().ensureInitialized(),
  ]);
  logger.i('Deferred storage warm-up complete');
}

void scheduleDeferredWarmUp() {
  unawaited(warmUpDeferredStorages());
}
