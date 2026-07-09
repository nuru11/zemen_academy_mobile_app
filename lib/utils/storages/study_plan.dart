import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/storages/base.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStudyPlanStorage extends BaseObjectStorage<List<StudyPlan>> {
  final String _boxName = 'studyPlanStorage';
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
  void listen(void Function(List<StudyPlan>) callback, String key) {
    ensureInitialized().then((_) {
      _box.watch(key: key).listen((event) {
        final value = event.value ?? [];
        callback(value.cast<StudyPlan>());
      });
    });
  }

  @override
  Future<List<StudyPlan>?> read(String key) async {
    await ensureInitialized();
    final value = _box.get(key) ?? [];
    return value.cast<StudyPlan>();
  }

  @override
  Future<void> write(String key, List<StudyPlan> value) async {
    await ensureInitialized();
    return _box.put(key, value);
  }

  Future<List<StudyPlan>> getStudyPlans() async {
    await ensureInitialized();
    final value = _box.get('study_plans') ?? [];
    return value.cast<StudyPlan>();
  }

  Future<void> setStudyPlans(List<StudyPlan> plans) async {
    await ensureInitialized();
    return _box.put('study_plans', plans);
  }

  Future<void> addStudyPlan(StudyPlan plan) async {
    final plans = await getStudyPlans();
    plans.add(plan);
    await setStudyPlans(plans);
  }

  Future<void> updateStudyPlan(StudyPlan plan) async {
    final plans = await getStudyPlans();
    final index = plans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      plans[index] = plan;
      await setStudyPlans(plans);
    }
  }

  Future<void> deleteStudyPlan(int id) async {
    final plans = await getStudyPlans();
    plans.removeWhere((p) => p.id == id);
    await setStudyPlans(plans);
  }
}
