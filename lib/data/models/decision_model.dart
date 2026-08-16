import 'package:cloud_firestore/cloud_firestore.dart';

/// Статус записи Квадрата Декарта.
enum DecisionStatus { draft, completed }

/// Документ `users/{uid}/decisions/{decisionId}` в Firestore
/// (или запись в Hive-боксе `decisions_cache` для анонимов/офлайн).
/// См. FLUTTER_ARCHITECTURE_PLAN.md §2.2.
class DecisionModel {
  const DecisionModel({
    required this.id,
    required this.userId,
    required this.doubtText,
    this.answerIfHappens = '',
    this.answerIfNotHappens = '',
    this.answerNotIfHappens = '',
    this.answerNotIfNotHappens = '',
    this.finalDecisionText = '',
    this.tag,
    this.status = DecisionStatus.draft,
    required this.locationIndexAtCreation,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.draftToCompleteSeconds,
    this.argumentCounts = const {},
    this.usedBackspace = true,
  });

  final String id;
  final String userId;

  /// Исходное сомнение — цитируется на всех экранах флоу.
  final String doubtText;

  /// Что будет, если это произойдёт?
  final String answerIfHappens;

  /// Что будет, если это НЕ произойдёт?
  final String answerIfNotHappens;

  /// Чего НЕ будет, если это произойдёт?
  final String answerNotIfHappens;

  /// Чего НЕ будет, если это НЕ произойдёт?
  final String answerNotIfNotHappens;

  /// Итоговое решение пользователя своими словами — свободный текст,
  /// вводится на экране «Принятие решения» рядом с категорией (tag).
  final String finalDecisionText;

  /// Категория для bubble chart и ачивки «Парад планет» (работа/отношения/покупки…).
  final String? tag;

  final DecisionStatus status;
  final int locationIndexAtCreation;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  /// Время «в черновике» — для «Разрушителя иллюзий» и эклипс-ачивок.
  final int? draftToCompleteSeconds;

  /// Число пунктов/строк в каждом из 4 блоков — ключи: q1, q2, q3, q4.
  /// Используется для «Мастера баланса» и «Глубокого анализа».
  final Map<String, int> argumentCounts;

  /// true, если пользователь ни разу не нажал backspace/delete при заполнении —
  /// условие секретной ачивки «Высота Орхехии».
  final bool usedBackspace;

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    return DecisionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      doubtText: json['doubtText'] as String? ?? '',
      answerIfHappens: json['answerIfHappens'] as String? ?? '',
      answerIfNotHappens: json['answerIfNotHappens'] as String? ?? '',
      answerNotIfHappens: json['answerNotIfHappens'] as String? ?? '',
      answerNotIfNotHappens: json['answerNotIfNotHappens'] as String? ?? '',
      finalDecisionText: json['finalDecisionText'] as String? ?? '',
      tag: json['tag'] as String?,
      status: DecisionStatus.values.byName(
        json['status'] as String? ?? 'draft',
      ),
      locationIndexAtCreation: json['locationIndexAtCreation'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
      draftToCompleteSeconds: json['draftToCompleteSeconds'] as int?,
      argumentCounts:
          Map<String, int>.from(json['argumentCounts'] as Map? ?? const {}),
      usedBackspace: json['usedBackspace'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'doubtText': doubtText,
      'answerIfHappens': answerIfHappens,
      'answerIfNotHappens': answerIfNotHappens,
      'answerNotIfHappens': answerNotIfHappens,
      'answerNotIfNotHappens': answerNotIfNotHappens,
      'finalDecisionText': finalDecisionText,
      'tag': tag,
      'status': status.name,
      'locationIndexAtCreation': locationIndexAtCreation,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'draftToCompleteSeconds': draftToCompleteSeconds,
      'argumentCounts': argumentCounts,
      'usedBackspace': usedBackspace,
    };
  }

  DecisionModel copyWith({
    String? doubtText,
    String? answerIfHappens,
    String? answerIfNotHappens,
    String? answerNotIfHappens,
    String? answerNotIfNotHappens,
    String? finalDecisionText,
    String? tag,
    DecisionStatus? status,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? draftToCompleteSeconds,
    Map<String, int>? argumentCounts,
    bool? usedBackspace,
  }) {
    return DecisionModel(
      id: id,
      userId: userId,
      doubtText: doubtText ?? this.doubtText,
      answerIfHappens: answerIfHappens ?? this.answerIfHappens,
      answerIfNotHappens: answerIfNotHappens ?? this.answerIfNotHappens,
      answerNotIfHappens: answerNotIfHappens ?? this.answerNotIfHappens,
      answerNotIfNotHappens:
          answerNotIfNotHappens ?? this.answerNotIfNotHappens,
      finalDecisionText: finalDecisionText ?? this.finalDecisionText,
      tag: tag ?? this.tag,
      status: status ?? this.status,
      locationIndexAtCreation: locationIndexAtCreation,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      draftToCompleteSeconds:
          draftToCompleteSeconds ?? this.draftToCompleteSeconds,
      argumentCounts: argumentCounts ?? this.argumentCounts,
      usedBackspace: usedBackspace ?? this.usedBackspace,
    );
  }
}
