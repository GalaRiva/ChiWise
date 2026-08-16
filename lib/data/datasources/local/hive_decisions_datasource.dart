import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../models/decision_model.dart';

/// Провайдер открытого Hive-бокса `decisions_cache`. `Hive.openBox<Map>(...)`
/// асинхронный, поэтому инстанс создаётся один раз в main.dart (await до
/// runApp) и прокидывается сюда через `ProviderScope(overrides: [...])` — тот
/// же паттерн, что и `sharedPreferencesProvider`
/// (см. data/datasources/local/shared_prefs_datasource.dart).
final Provider<Box<Map>> decisionsBoxProvider = Provider<Box<Map>>((ref) {
  throw UnimplementedError(
    'decisionsBoxProvider должен быть переопределён в main.dart через '
    'ProviderScope(overrides: [decisionsBoxProvider.overrideWithValue(box)])',
  );
});

/// Локальный (офлайн/анонимный) источник данных для черновиков и решений —
/// Hive-бокс `decisions_cache`, ключ записи — `DecisionModel.id`.
///
/// ВАЖНО: намеренно НЕ используем `DecisionModel.toJson()/fromJson()` — они
/// рассчитаны на `cloud_firestore.Timestamp` (см. комментарий в начале
/// decision_model.dart, синхронизация с Firestore — Этап 3). Здесь даты
/// хранятся как `millisecondsSinceEpoch` (int), а сериализация/десериализация
/// написана вручную поверх обычного конструктора `DecisionModel` (все поля
/// публичные final). Box типизирован как `Box<Map>` без кастомных
/// Hive-адаптеров — используются только «нативные» для Hive типы (String,
/// int, bool, Map, null), адаптеры для них не нужны.
class HiveDecisionsDatasource {
  const HiveDecisionsDatasource(this._box);

  final Box<Map> _box;

  Future<void> saveDraft(DecisionModel decision) {
    return _box.put(decision.id, _toMap(decision));
  }

  DecisionModel? getDraft(String id) {
    final Map? raw = _box.get(id);
    if (raw == null) return null;
    return _fromMap(raw);
  }

  Future<void> deleteDraft(String id) => _box.delete(id);

  List<DecisionModel> getAllDrafts(String userId) {
    return _box.values
        .map(_fromMap)
        .where((decision) => decision.userId == userId)
        .toList();
  }

  // --- Сериализация ---

  Map<String, dynamic> _toMap(DecisionModel decision) {
    return {
      'id': decision.id,
      'userId': decision.userId,
      'doubtText': decision.doubtText,
      'answerIfHappens': decision.answerIfHappens,
      'answerIfNotHappens': decision.answerIfNotHappens,
      'answerNotIfHappens': decision.answerNotIfHappens,
      'answerNotIfNotHappens': decision.answerNotIfNotHappens,
      'finalDecisionText': decision.finalDecisionText,
      'tag': decision.tag,
      'status': decision.status.name,
      'locationIndexAtCreation': decision.locationIndexAtCreation,
      'createdAt': decision.createdAt.millisecondsSinceEpoch,
      'updatedAt': decision.updatedAt.millisecondsSinceEpoch,
      'completedAt': decision.completedAt?.millisecondsSinceEpoch,
      'draftToCompleteSeconds': decision.draftToCompleteSeconds,
      'argumentCounts': decision.argumentCounts,
      'usedBackspace': decision.usedBackspace,
    };
  }

  DecisionModel _fromMap(Map raw) {
    // Hive при чтении с диска отдаёт `Map` без гарантированной статической
    // типизации ключей/значений (реализация binary-ридера возвращает общий
    // `Map`, не обязательно `Map<String, dynamic>`), поэтому явно приводим
    // тип через `Map<String, dynamic>.from(...)` вместо `as Map<String, dynamic>`,
    // который может бросить исключение приведения типа.
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
    final Map<String, int> argumentCounts = map['argumentCounts'] == null
        ? const {}
        : Map<String, int>.from(map['argumentCounts'] as Map);

    return DecisionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      doubtText: map['doubtText'] as String? ?? '',
      answerIfHappens: map['answerIfHappens'] as String? ?? '',
      answerIfNotHappens: map['answerIfNotHappens'] as String? ?? '',
      answerNotIfHappens: map['answerNotIfHappens'] as String? ?? '',
      answerNotIfNotHappens: map['answerNotIfNotHappens'] as String? ?? '',
      finalDecisionText: map['finalDecisionText'] as String? ?? '',
      tag: map['tag'] as String?,
      status:
          DecisionStatus.values.byName(map['status'] as String? ?? 'draft'),
      locationIndexAtCreation: map['locationIndexAtCreation'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int),
      draftToCompleteSeconds: map['draftToCompleteSeconds'] as int?,
      argumentCounts: argumentCounts,
      usedBackspace: map['usedBackspace'] as bool? ?? true,
    );
  }
}

final Provider<HiveDecisionsDatasource> hiveDecisionsDatasourceProvider =
    Provider<HiveDecisionsDatasource>((ref) {
  final Box<Map> box = ref.watch(decisionsBoxProvider);
  return HiveDecisionsDatasource(box);
});
