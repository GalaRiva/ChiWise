import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

/// Анимированный сплэш — показывается ровно один раз при холодном старте,
/// сразу после нативного (статичного, платформенного) splash screen'а.
/// Нативный splash не умеет анимацию, поэтому логотип
/// (assets/icon/splash_logo.png, тот же файл, что и в
/// flutter_native_splash) оживает уже здесь — плавно проявляется и
/// масштабируется на том же фоне (AppColors.deepBlue), чтобы переход с
/// нативного экрана был бесшовным.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    // Один AnimationController на весь показ сплэша (не отдельный
    // Future.delayed) — так и виджет-тесты (`tester.pumpAndSettle()`), и
    // реальный рантайм ждут ровно одно и то же: fade/scale укладываются в
    // первые ~40%, дальше контроллер просто "держит" логотип на экране до
    // конца длительности, после чего уходим на onboarding.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _controller.addStatusListener((status) {
      // redirect в app_router.dart сам решит, куда именно (онбординг/вход/
      // карта), см. AppRoutes.splash — сюда достаточно просто уйти со
      // сплэша.
      if (status == AnimationStatus.completed && mounted) {
        context.go(AppRoutes.onboarding);
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Image.asset(
              'assets/icon/splash_logo.png',
              width: 220,
              height: 220,
            ),
          ),
        ),
      ),
    );
  }
}
