import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Категория ачивки — определяет группировку в галерее.
enum AchievementCategory { behavioral, analytical, narrativeAstro, magicBall }

/// Статический конфиг ачивки (не хранится в Firestore — факт получения
/// живёт в UserModel.achievements). См. FLUTTER_ARCHITECTURE_PLAN.md §2.4.
class AchievementModel {
  const AchievementModel({
    required this.key,
    required this.category,
    this.isSecret = false,
    required this.titleKey,
    this.riddleTextKey,
    this.descriptionKey,
    required this.gradientColors,
    this.quoteKey,
  });

  final String key;
  final AchievementCategory category;

  /// Если true — до разгадки карточка показывает riddleTextKey под матовым
  /// стеклом со знаком "?" вместо иконки (см. presentation/widgets/swatch_card.dart).
  final bool isSecret;

  final String titleKey;

  /// Загадка-подсказка — видна вместо descriptionKey, пока isSecret && !unlocked.
  final String? riddleTextKey;

  /// Реальное условие получения — видно всегда для несекретных ачивок,
  /// и секретным после разгадки.
  final String? descriptionKey;

  final List<Color> gradientColors;

  /// Цитата на обратной стороне карточки (3D-флип).
  final String? quoteKey;

  /// MVP-список: 9 обычных + 4 секретных ачивки, зафиксированы в ТЗ/переписке 2026-08-15.
  static const List<AchievementModel> all = [
    // --- Поведенческие ---
    AchievementModel(
      key: 'orbital_stability',
      category: AchievementCategory.behavioral,
      titleKey: 'achOrbitalStabilityTitle',
      descriptionKey: 'achOrbitalStabilityDesc',
      gradientColors: [AppColors.deepBlue, AppColors.turquoise],
    ),
    AchievementModel(
      key: 'night_owl_sage',
      category: AchievementCategory.behavioral,
      titleKey: 'achNightOwlSageTitle',
      descriptionKey: 'achNightOwlSageDesc',
      gradientColors: [AppColors.deepBlue, AppColors.deepBlueLight],
    ),

    // --- Аналитические ---
    AchievementModel(
      key: 'balance_master',
      category: AchievementCategory.analytical,
      titleKey: 'achBalanceMasterTitle',
      descriptionKey: 'achBalanceMasterDesc',
      gradientColors: [AppColors.emerald, AppColors.turquoise],
    ),
    AchievementModel(
      key: 'deep_analysis',
      category: AchievementCategory.analytical,
      titleKey: 'achDeepAnalysisTitle',
      descriptionKey: 'achDeepAnalysisDesc',
      gradientColors: [AppColors.deepBlue, AppColors.softGold],
    ),
    AchievementModel(
      key: 'illusion_breaker',
      category: AchievementCategory.analytical,
      titleKey: 'achIllusionBreakerTitle',
      descriptionKey: 'achIllusionBreakerDesc',
      gradientColors: [AppColors.deepBlueLight, AppColors.emerald],
    ),

    // --- Сюжетные / астрономические ---
    AchievementModel(
      key: 'eclipse_catcher',
      category: AchievementCategory.narrativeAstro,
      titleKey: 'achEclipseCatcherTitle',
      descriptionKey: 'achEclipseCatcherDesc',
      gradientColors: [AppColors.deepBlue, AppColors.softGold],
    ),
    AchievementModel(
      key: 'planet_parade',
      category: AchievementCategory.narrativeAstro,
      titleKey: 'achPlanetParadeTitle',
      descriptionKey: 'achPlanetParadeDesc',
      gradientColors: [AppColors.emerald, AppColors.softGold],
    ),
    AchievementModel(
      key: 'light_mind',
      category: AchievementCategory.narrativeAstro,
      titleKey: 'achLightMindTitle',
      descriptionKey: 'achLightMindDesc',
      gradientColors: [AppColors.turquoise, AppColors.softGold],
    ),

    // --- Магический Шар ---
    AchievementModel(
      key: 'magic_resonance',
      category: AchievementCategory.magicBall,
      titleKey: 'achMagicResonanceTitle',
      descriptionKey: 'achMagicResonanceDesc',
      gradientColors: [AppColors.deepBlue, AppColors.turquoise],
    ),
    AchievementModel(
      key: 'fate_tester',
      category: AchievementCategory.magicBall,
      titleKey: 'achFateTesterTitle',
      descriptionKey: 'achFateTesterDesc',
      gradientColors: [AppColors.deepBlueLight, AppColors.softGold],
    ),

    // --- Секретные (isSecret: true) ---
    AchievementModel(
      key: 'eclipse_observer',
      category: AchievementCategory.narrativeAstro,
      isSecret: true,
      titleKey: 'achEclipseObserverTitle',
      riddleTextKey: 'achEclipseObserverRiddle',
      descriptionKey: 'achEclipseObserverDesc',
      gradientColors: [AppColors.deepBlue, AppColors.softGold],
      quoteKey: 'achEclipseObserverQuote',
    ),
    AchievementModel(
      key: 'perfect_alignment',
      category: AchievementCategory.narrativeAstro,
      isSecret: true,
      titleKey: 'achPerfectAlignmentTitle',
      riddleTextKey: 'achPerfectAlignmentRiddle',
      descriptionKey: 'achPerfectAlignmentDesc',
      gradientColors: [AppColors.emerald, AppColors.turquoise],
      quoteKey: 'achPerfectAlignmentQuote',
    ),
    AchievementModel(
      key: 'orhekia_height',
      category: AchievementCategory.analytical,
      isSecret: true,
      titleKey: 'achOrhekiaHeightTitle',
      riddleTextKey: 'achOrhekiaHeightRiddle',
      descriptionKey: 'achOrhekiaHeightDesc',
      gradientColors: [AppColors.deepBlue, AppColors.softGold],
      quoteKey: 'achOrhekiaHeightQuote',
    ),
    AchievementModel(
      key: 'oracle_whisper',
      category: AchievementCategory.magicBall,
      isSecret: true,
      titleKey: 'achOracleWhisperTitle',
      riddleTextKey: 'achOracleWhisperRiddle',
      descriptionKey: 'achOracleWhisperDesc',
      gradientColors: [AppColors.deepBlue, AppColors.turquoise],
      quoteKey: 'achOracleWhisperQuote',
    ),
  ];
}
