import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/decision_model.dart';
import '../../../data/models/decision_tag.dart';

/// "Bubble chart" истории решений (Этап 10b, см. FLUTTER_ARCHITECTURE_PLAN.md
/// и исходные требования проекта: "size based on text volume, color based on
/// category"). fl_chart не имеет отдельного bubble-chart виджета — рисуем
/// через ScatterChart, у каждой точки свой радиус (= объём текста решения) и
/// цвет (= категория, см. DecisionTagOption).
class DecisionBubbleChart extends StatelessWidget {
  const DecisionBubbleChart({super.key, required this.decisions});

  /// Только ЗАВЕРШЁННЫЕ решения (status == completed) — вызывающий код
  /// (stats_screen.dart) сам фильтрует перед передачей сюда.
  final List<DecisionModel> decisions;

  /// Суммарный объём текста решения — сумма всех значений argumentCounts
  /// (q1..q4), прокси для "сколько текста написано".
  int _volumeOf(DecisionModel decision) {
    if (decision.argumentCounts.isEmpty) return 1; // минимум 1, чтобы пузырь был виден
    final int sum = decision.argumentCounts.values.fold(0, (a, b) => a + b);
    return sum < 1 ? 1 : sum;
  }

  @override
  Widget build(BuildContext context) {
    if (decisions.isEmpty) {
      return const SizedBox.shrink(); // экран сам показывает statsEmptyState
    }

    final int maxVolume = decisions.map(_volumeOf).reduce((a, b) => a > b ? a : b);

    final List<ScatterSpot> spots = [];
    for (int i = 0; i < decisions.length; i++) {
      final DecisionModel decision = decisions[i];
      final int volume = _volumeOf(decision);
      // Радиус пузыря: от 6 до 26px в зависимости от объёма текста
      // относительно самого "объёмного" решения в списке.
      final double radius = 6 + (26 - 6) * (volume / maxVolume);
      final DecisionTagOption? tagOption = DecisionTagOption.byKey(decision.tag);
      final Color color = (tagOption?.color ?? Colors.grey).withValues(alpha: 0.75);

      spots.add(
        ScatterSpot(
          i.toDouble(), // X — порядковый номер решения (хронология)
          volume.toDouble(), // Y — объём текста
          dotPainter: FlDotCirclePainter(radius: radius, color: color),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.4,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: spots,
          minX: -1,
          maxX: decisions.length.toDouble(),
          minY: 0,
          maxY: maxVolume.toDouble() + 2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          scatterTouchData: ScatterTouchData(enabled: false),
        ),
      ),
    );
  }
}
