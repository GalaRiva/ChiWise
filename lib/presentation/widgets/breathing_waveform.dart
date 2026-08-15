import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Визуальный "пульс" интерфейса, отражающий скорость ввода текста —
/// хаотичные острые волны при быстром наборе, плавные при паузах/медленном
/// вводе. НЕ использует пакет audio_waveforms (см. комментарий в вызывающем
/// коде _AnswerField, decision_flow_screen.dart) — рисуется собственным
/// CustomPainter, т.к. в приложении нет реального аудио для визуализации:
/// audio_waveforms спроектирован вокруг RecorderController/PlayerController
/// с реальными аудио-сэмплами, здесь же "хаос" — чисто визуальная метафора,
/// управляемая скоростью набора текста (см. Этап 8 — по аналогии там
/// 3D-флип ачивки заменён на AnimatedSwitcher вместо рискованной
/// Matrix4-трансформации).
class BreathingWaveform extends StatefulWidget {
  const BreathingWaveform({super.key, required this.chaos});

  /// 0.0 (полный штиль/пауза) .. 1.0 (максимально быстрый, "нервный" набор).
  final double chaos;

  @override
  State<BreathingWaveform> createState() => _BreathingWaveformState();
}

class _BreathingWaveformState extends State<BreathingWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _phaseController;

  @override
  void initState() {
    super.initState();
    // Непрерывный "бегущий" цикл волны — независим от chaos, тот отвечает
    // только за амплитуду/частоту/дрожание, а не за то, идёт ли анимация.
    _phaseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double clampedChaos = widget.chaos.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      // Плавный переход амплитуды/цвета между уровнями chaos (напр. когда
      // пользователь резко останавливает быстрый набор) — сама фаза волны
      // при этом продолжает бежать через _phaseController ниже.
      tween: Tween<double>(begin: 0.0, end: clampedChaos),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, animatedChaos, child) {
        return AnimatedBuilder(
          animation: _phaseController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(double.infinity, 36),
              painter: _WavePainter(
                phase: _phaseController.value * 2 * pi,
                chaos: animatedChaos,
              ),
            );
          },
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.phase, required this.chaos});

  final double phase;
  final double chaos;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;

    // Цвет: от спокойной бирюзы/изумруда (AppColors.waveformCalm) к тревожному
    // оранжевому (AppColors.waveformChaotic) — плавный лерп по chaos.
    final Color calmColor = AppColors.waveformCalm.first;
    final Color color =
        Color.lerp(calmColor, AppColors.waveformChaotic, chaos) ?? calmColor;

    // Амплитуда и частота растут вместе с chaos: спокойная волна — низкая и
    // редкая, "нервная" — высокая и частая.
    final double amplitude = 3.0 + (15.0 - 3.0) * chaos;
    final double frequency = 1.0 + (4.5 - 1.0) * chaos;

    const int pointCount = 50;
    final Path path = Path();

    for (int i = 0; i <= pointCount; i++) {
      final double t = i / pointCount;
      final double x = t * size.width;

      double y = centerY + amplitude * sin(frequency * t * 2 * pi + phase);

      if (chaos > 0) {
        // Детерминированный "шум" от индекса точки и текущего уровня chaos —
        // не зависит от времени/кадра напрямую (не System.currentTimeMillis/
        // DateTime.now()), поэтому paint() воспроизводим для одного и того
        // же (phase, chaos) и не мерцает случайно на каждом кадре сверх
        // собственного движения фазы волны.
        final Random pointRandom = Random(i * 97 + (chaos * 1000).round());
        final double jitter =
            (pointRandom.nextDouble() * 2 - 1) * amplitude * 0.3 * chaos;
        y += jitter;
      }

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.chaos != chaos;
  }
}
