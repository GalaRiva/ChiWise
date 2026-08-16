import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/models/location_model.dart';
import '../../../data/repositories/decision_repository_impl.dart';
import '../../../domain/repositories/decision_repository.dart';
import '../../providers/auth_provider.dart';
import '../home_map/home_map_screen.dart' show locationName;

/// Полноэкранное изображение локации с флажками — по одному на каждое
/// ЗАВЕРШЁННОЕ решение, принятое здесь (`DecisionModel.locationIndexAtCreation`),
/// см. фидбэк: "нажимая на карточку локации, должно открываться полное
/// изображение, на котором расставляются флажки — каждое решение - один
/// флажок". Открывается тапом по карточке на карте (см. home_map_screen.dart,
/// маршрут `AppRoutes.locationDetail`).
///
/// У решений нет сохранённых координат на изображении — позиции флажков
/// детерминированные (не меняются между открытиями экрана): раскладка по
/// сетке ~4 колонки + небольшой сдвиг, зависящий от `decision.id`, чтобы
/// флажки не ложились ровно друг на друга при нескольких решениях подряд.
class LocationDetailScreen extends ConsumerWidget {
  const LocationDetailScreen({super.key, required this.locationIndex});

  final int locationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final LocationModel location = LocationModel.locations[locationIndex];

    final AuthState authState = ref.read(authNotifierProvider);
    final String? userId =
        authState is AuthStateAuthenticated ? authState.uid : null;
    final DecisionRepository repository = ref.read(decisionRepositoryProvider);

    final List<DecisionModel> decisions = userId == null
        ? const []
        : repository
            .getAllDrafts(userId)
            .where((decision) =>
                decision.locationIndexAtCreation == locationIndex &&
                decision.status == DecisionStatus.completed)
            .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          locationName(l10n, location.nameKey),
          style: AppTextStyles.titleMedium.copyWith(
            shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(location.backgroundAsset, fit: BoxFit.cover),
          // Затемнение сверху (под AppBar) и снизу — так заголовок и
          // флажки у самого низа картинки остаются читаемыми на любом фоне.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB30B1D3A),
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x800B1D3A),
                ],
                stops: [0.0, 0.18, 0.75, 1.0],
              ),
            ),
          ),
          if (decisions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.homeMapNoDecisionsHere,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
                  ),
                ),
              ),
            )
          else
            for (int i = 0; i < decisions.length; i++)
              _DecisionFlag(
                decision: decisions[i],
                index: i,
                total: decisions.length,
                onTap: () =>
                    context.push(AppRoutes.decisionDetailPath(decisions[i].id)),
              ),
        ],
      ),
    );
  }
}

/// Один флажок на изображении локации — деterministически позиционирован
/// по индексу решения в списке + хэшу его id (см. комментарий класса выше).
class _DecisionFlag extends StatelessWidget {
  const _DecisionFlag({
    required this.decision,
    required this.index,
    required this.total,
    required this.onTap,
  });

  final DecisionModel decision;
  final int index;
  final int total;
  final VoidCallback onTap;

  static const int _columns = 4;

  Alignment get _alignment {
    final int row = index ~/ _columns;
    final int col = index % _columns;
    final int rows = (total / _columns).ceil();

    const double cellW = 1.0 / _columns;
    // Безопасная вертикальная полоса 22%-82% высоты экрана — не залезает
    // ни под AppBar сверху, ни под системные жесты снизу.
    final double cellH = rows <= 1 ? 0.60 : 0.60 / rows;

    final int hash = decision.id.hashCode;
    final double jitterX = (((hash % 1000) / 1000) - 0.5) * cellW * 0.6;
    final double jitterY = ((((hash ~/ 1000) % 1000) / 1000) - 0.5) * cellH * 0.6;

    final double fx = ((col + 0.5) * cellW + jitterX).clamp(0.08, 0.92);
    final double fy = (0.22 + (row + 0.5) * cellH + jitterY).clamp(0.22, 0.82);

    // Alignment использует диапазон -1..1, а не 0..1.
    return Alignment(fx * 2 - 1, fy * 2 - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.softGold,
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.flag, color: AppColors.deepBlue, size: 22),
        ),
      ),
    );
  }
}
