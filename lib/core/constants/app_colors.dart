import 'package:flutter/material.dart';

/// Палитра из ТЗ: Deep Blue, Emerald, Turquoise, Soft Gold.
/// Используется вместо хардкода цветов по всему приложению.
class AppColors {
  AppColors._();

  static const Color deepBlue = Color(0xFF0B1D3A);
  static const Color deepBlueLight = Color(0xFF14284F);
  static const Color emerald = Color(0xFF1FAE83);
  static const Color turquoise = Color(0xFF2EC4C6);
  static const Color softGold = Color(0xFFE8C170);

  static const Color background = deepBlue;
  static const Color surface = deepBlueLight;
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFA8B4C7);

  /// Хаотичные волны при быстром вводе текста (импульсивность) — audio_waveforms, Этап 10.
  static const Color waveformChaotic = Color(0xFFFF8A5B);

  /// Плавные волны при замедлении ввода (осознанность) — audio_waveforms, Этап 10.
  static const List<Color> waveformCalm = [emerald, turquoise];

  /// Мягкая подсветка для неоморфных карточек/кнопок.
  static const LinearGradient neumorphicHighlight = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Тени неоморфизма (тёмный фон): один свет, одна тень.
  static const Color neumorphicShadowDark = Color(0xFF061225);
  static const Color neumorphicShadowLight = Color(0xFF1C3564);
}
