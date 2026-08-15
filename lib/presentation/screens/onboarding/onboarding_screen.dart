import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../providers/onboarding_provider.dart';

/// Онбординг — 4 свайп-экрана (PageView), см. FLUTTER_ARCHITECTURE_PLAN.md,
/// Этап 1. Тексты — из ТЗ, ключи onboardingTitle1..4
/// (lib/core/localization/l10n/*.arb).
///
/// Переход дальше (на экран авторизации) происходит не через явную
/// навигацию, а через redirect в go_router: как только флаг онбординга
/// сохранён в SharedPreferences (см. presentation/providers/onboarding_provider.dart),
/// appRouterProvider пересобирается и redirect уводит пользователя на /auth
/// (см. core/router/app_router.dart).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _pageCount = 4;

  final PageController _pageController = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
  }

  void _onNextPressed() {
    if (_pageIndex < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  List<String> _titles(AppLocalizations l10n) => [
        l10n.onboardingTitle1,
        l10n.onboardingTitle2,
        l10n.onboardingTitle3,
        l10n.onboardingTitle4,
      ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<String> titles = _titles(l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                  vertical: 8,
                ),
                child: TextButton.icon(
                  onPressed: _finishOnboarding,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                  ),
                  label: Text(
                    l10n.onboardingSkip,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pageCount,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.screenPadding * 1.5,
                    ),
                    child: Center(
                      child: Text(
                        titles[index],
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLarge,
                      ),
                    ),
                  );
                },
              ),
            ),
            _DotsIndicator(count: _pageCount, activeIndex: _pageIndex),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  child: Text(l10n.onboardingNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Точечный индикатор прогресса онбординга.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.turquoise : AppColors.textSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
