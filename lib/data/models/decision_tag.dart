import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Категория решения — используется для чипов выбора на экране «Принятие
/// решения» (decision_summary_screen.dart) и для цвета/легенды bubble chart
/// на экране статистики (Этап 10b). Хранится как обычная строка в
/// `DecisionModel.tag` (см. модель — там уже есть комментарий
/// "работа/отношения/покупки…"), НЕ как enum, чтобы не потребовалась миграция
/// уже сохранённых значений при добавлении новых категорий в будущем.
class DecisionTagOption {
  const DecisionTagOption({
    required this.key,
    required this.labelKey,
    required this.color,
  });

  /// Технический ключ — то самое значение, что пишется в `DecisionModel.tag`.
  final String key;

  /// Ключ локализации названия (см. l10n.decisionTagXxx).
  final String labelKey;

  final Color color;

  static const List<DecisionTagOption> all = [
    DecisionTagOption(key: 'work', labelKey: 'decisionTagWork', color: AppColors.turquoise),
    DecisionTagOption(key: 'relationships', labelKey: 'decisionTagRelationships', color: AppColors.softGold),
    DecisionTagOption(key: 'health', labelKey: 'decisionTagHealth', color: AppColors.emerald),
    DecisionTagOption(key: 'finances', labelKey: 'decisionTagFinances', color: AppColors.deepBlueLight),
    DecisionTagOption(key: 'personal_growth', labelKey: 'decisionTagPersonalGrowth', color: AppColors.waveformChaotic),
    DecisionTagOption(key: 'other', labelKey: 'decisionTagOther', color: AppColors.textSecondary),
  ];

  /// Ищет опцию по `DecisionModel.tag` (может быть `null` — тогда возвращает
  /// `null`, вызывающий код сам решает, что показать в этом случае).
  static DecisionTagOption? byKey(String? key) {
    if (key == null) return null;
    for (final DecisionTagOption option in all) {
      if (option.key == key) return option;
    }
    return null;
  }
}
