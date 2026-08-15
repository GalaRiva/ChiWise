import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Тонкая обёртка над встроенным `HapticFeedback`
/// (`package:flutter/services.dart`) — используется вместо стороннего пакета
/// `haptic_feedback` (см. задание Этапа 5, п.3: пакет оставлен в pubspec.yaml
/// про запас, но не задействован в коде, т.к. не может быть проверен
/// компиляцией в этой среде без Flutter SDK).
///
/// Остальной код (напр. `presentation/providers/magic_ball_provider.dart`)
/// зависит от этого сервиса, а не от `HapticFeedback` напрямую — легче
/// заменить/замокать в тестах позже.
class HapticsService {
  const HapticsService();

  /// Лёгкий тик — начало действия/обратная связь на незначительное событие.
  void lightTick() => HapticFeedback.lightImpact();

  /// Средний тик — используется в начале "раздумий" Магического Шара.
  void mediumTick() => HapticFeedback.mediumImpact();

  /// Сильный тик — используется перед показом ответа Магического Шара
  /// ("нарастающая вибрация", см. ТЗ).
  void strongTick() => HapticFeedback.heavyImpact();
}

final Provider<HapticsService> hapticsServiceProvider =
    Provider<HapticsService>((ref) => const HapticsService());
