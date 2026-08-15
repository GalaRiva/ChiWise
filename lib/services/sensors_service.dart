import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Обёртка над `sensors_plus` (акселерометр) для экрана Магического Шара
/// (Этап 5, см. FLUTTER_ARCHITECTURE_PLAN.md §5 и §2 "Сенсоры и тактильность").
///
/// Презентационный слой не должен знать про сырую магнитуду вектора
/// акселерометра/гравитацию — сервис публикует уже нормализованную
/// "интенсивность тряски" (0.0 — покой, 1.0 — максимальная тряска).
class SensorsService {
  SensorsService() {
    _init();
  }

  /// Модуль вектора акселерометра в покое (гравитация Земли, м/с²).
  static const double _baseline = 9.8;

  /// Дельта магнитуды, которая считается "максимальной" тряской (1.0) —
  /// подобрано эмпирически, не проверено на реальном устройстве в этой
  /// среде разработки (нет Flutter SDK/эмулятора, см. задание Этапа 5, п.3).
  static const double _maxDelta = 15.0;

  final StreamController<double> _controller =
      StreamController<double>.broadcast();

  StreamSubscription<AccelerometerEvent>? _subscription;

  /// 0.0-1.0, нормализованная интенсивность тряски. Если акселерометр
  /// недоступен на этой платформе (см. try/catch в [_init]) — поток просто
  /// никогда не эмитит значений, а не бросает исключение подписчикам.
  Stream<double> get shakeIntensity => _controller.stream;

  void _init() {
    // ВАЖНО (тот же паттерн, что и в AuthNotifier.build(), см.
    // presentation/providers/auth_provider.dart): обращение к сторонним SDK
    // (тут — платформенный канал sensors_plus) заворачивается в try/catch у
    // вызывающей стороны, т.к. на некоторых эмуляторах/платформах датчик
    // акселерометра может отсутствовать и подписка бросит исключение.
    try {
      // TODO(sensors_plus 6.0.1): сверить точное имя API при первой реальной
      // сборке проекта (нет доступа к Flutter/Dart SDK и pub.dev в этой
      // песочнице, см. задание Этапа 5, п.3). Наиболее вероятный актуальный
      // API для этой версии пакета — метод `accelerometerEventStream()`
      // (пришёл на смену устаревшему геттеру `accelerometerEvents` из более
      // ранних версий sensors_plus). Если сигнатура/имя иные — заменить
      // строку ниже.
      _subscription = accelerometerEventStream().listen(
        _onEvent,
        onError: (Object _, StackTrace __) {
          // Платформенная ошибка потока в рантайме (напр. датчик отвалился)
          // — молча игнорируем, поток просто перестаёт публиковать события.
        },
      );
    } catch (_) {
      // Акселерометр недоступен вовсе (нет датчика/платформенного канала) —
      // сервис остаётся "тихим": shakeIntensity никогда не эмитит > 0, но
      // экран Магического Шара всё равно работает через кнопку "Спросить".
    }
  }

  void _onEvent(AccelerometerEvent event) {
    if (_controller.isClosed) return;
    final double magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final double delta = (magnitude - _baseline).clamp(0, _maxDelta);
    final double normalized = (delta / _maxDelta).clamp(0.0, 1.0);
    _controller.add(normalized);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

final Provider<SensorsService> sensorsServiceProvider =
    Provider<SensorsService>((ref) {
  final SensorsService service = SensorsService();
  ref.onDispose(service.dispose);
  return service;
});
