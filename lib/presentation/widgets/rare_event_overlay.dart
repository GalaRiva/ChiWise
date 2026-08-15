import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Декоративный оверлей редкого небесного явления (затмение, парад планет) —
/// показывается поверх карточки ТЕКУЩЕЙ локации на карте, когда у
/// пользователя streak >= 3 (см. LocationModel.rareEventAssets,
/// data/models/location_model.dart). Реальных .json-файлов анимаций в
/// проекте пока нет (заготовки путей на будущее для дизайнера) — используем
/// errorBuilder, чтобы отсутствующий asset не ронял экран, а просто ничего
/// не показывал (тот же защитный паттерн, что и для Firebase/RevenueCat в
/// остальном проекте — см. services/purchases_service.dart).
class RareEventOverlay extends StatelessWidget {
  const RareEventOverlay({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Декоративный слой не должен перехватывать тапы по карточке локации.
      child: Opacity(
        opacity: 0.55,
        child: Lottie.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
