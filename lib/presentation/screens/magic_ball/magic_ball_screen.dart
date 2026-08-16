import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../providers/magic_ball_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';

/// Экран Магического Шара (маршрут `AppRoutes.magicBall`, Этап 5, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §5). Пользователь либо жмёт кнопку
/// `l10n.magicBallAsk`, либо трясёт телефон — оба пути ведут к одному и тому
/// же `MagicBallNotifier.ask()` (см. presentation/providers/magic_ball_provider.dart).
///
/// ВАЖНО: тут намеренно нет поля ввода вопроса — пользователь ничего не
/// печатает, Шару не сообщается сам вопрос (см. задание Этапа 5).
class MagicBallScreen extends ConsumerStatefulWidget {
  const MagicBallScreen({super.key});

  @override
  ConsumerState<MagicBallScreen> createState() => _MagicBallScreenState();
}

class _MagicBallScreenState extends ConsumerState<MagicBallScreen> {
  @override
  void dispose() {
    // Уходим с экрана — сбрасываем "залипший" ответ/причину блокировки, см.
    // MagicBallNotifier.reset().
    ref.read(magicBallProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? user = ref.watch(userProfileProvider);
    final MagicBallState state = ref.watch(magicBallProvider);
    final MagicBallNotifier notifier = ref.read(magicBallProvider.notifier);

    // Живая локаль экрана — НЕ `user.languageCode` (оно пока нигде не
    // обновляется), см. задание Этапа 5, пункт E.
    final String languageCode = Localizations.localeOf(context).languageCode;
    notifier.setLanguageCode(languageCode);

    // Прокидываем интенсивность тряски из sensors_service в нотифаер —
    // ref.listen сам отписывается вместе с жизненным циклом этого виджета.
    ref.listen<AsyncValue<double>>(shakeIntensityStreamProvider, (previous, next) {
      next.whenData(notifier.updateShakeIntensity);
    });

    if (user == null) {
      // Профиль ещё грузится (см. UserProfileNotifier.build()) — тот же
      // паттерн, что и в HomeMapScreen.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.softGold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            children: [
              Text(
                l10n.magicBallWarning,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              _EnergyIndicator(energy: user.magicBallEnergy),
              const Spacer(),
              _MagicBallVisual(
                isAsking: state.isAsking,
                answerText: state.answerText,
                shakeIntensity: state.shakeIntensity,
                onTap: state.isAsking ? null : () => notifier.ask(languageCode),
              ),
              const SizedBox(height: 24),
              // Дублирует надпись изнутри шара — крупным шрифтом, чтобы
              // точно читалось (см. задание: "текст ... в достаточном
              // размере, чтобы точно все могли прочитать"). Пока ответа нет —
              // явная подсказка "нажми или тряхни" крупнее и заметнее
              // обычного вторичного текста, чтобы точно бросалась в глаза.
              SizedBox(
                height: 84,
                child: Center(
                  child: state.isAsking
                      ? const CircularProgressIndicator(color: AppColors.turquoise)
                      : Text(
                          state.answerText ?? l10n.magicBallShakeHint,
                          textAlign: TextAlign.center,
                          style: state.answerText == null
                              ? AppTextStyles.bodyLarge
                                  .copyWith(color: AppColors.turquoise)
                              : AppTextStyles.headlineLarge
                                  .copyWith(color: AppColors.softGold),
                        ),
                ),
              ),
              const Spacer(),
              if (state.blockReason == MagicBallBlockReason.limitReached)
                _BlockCard(
                  message: l10n.magicBallLimitReachedMessage,
                  buttonLabel: l10n.magicBallGoToPaywall,
                  onPressed: () => context.push(AppRoutes.paywall),
                )
              else if (state.blockReason == MagicBallBlockReason.lowEnergy)
                _BlockCard(
                  message: l10n.magicBallLowEnergyMessage,
                  buttonLabel: l10n.magicBallGoToDecision,
                  onPressed: () => context.push(AppRoutes.homeMap),
                )
              else
                NeumorphicButton(
                  label: l10n.magicBallAsk,
                  onPressed: state.isAsking ? null : () => notifier.ask(languageCode),
                ),
              const SizedBox(height: 12),
              NeumorphicButton(
                label: l10n.magicBallReturn,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.homeMap);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Простой индикатор энергии Шара (0-100) — `LinearProgressIndicator`,
/// цвет меняется на "тревожный" ниже стоимости одного вопроса.
class _EnergyIndicator extends StatelessWidget {
  const _EnergyIndicator({required this.energy});

  final int energy;

  @override
  Widget build(BuildContext context) {
    final bool isLow = energy < kMagicBallEnergyCost;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (energy / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              isLow ? AppColors.waveformChaotic : AppColors.turquoise,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('$energy / 100', style: AppTextStyles.bodySecondary),
      ],
    );
  }
}

/// Визуальный элемент "шар" — картинка `assets/images/icons/magic_ball.webp`
/// (предоставлена дизайнером), с реакцией на тряску (scale/glow) и
/// анимацией "думает": мягкое дыхание + вращающееся кольцо энергии вместо
/// плоского чёрного затемнения, затем проявление ответа светящимся текстом
/// внутри стеклянного окошка. Таймер завязан на `MagicBallNotifier.ask()` —
/// там пауза "шар думает" ровно 800мс (см. magic_ball_provider.dart).
class _MagicBallVisual extends StatefulWidget {
  const _MagicBallVisual({
    required this.isAsking,
    required this.answerText,
    required this.shakeIntensity,
    required this.onTap,
  });

  final bool isAsking;
  final String? answerText;
  final double shakeIntensity;
  final VoidCallback? onTap;

  @override
  State<_MagicBallVisual> createState() => _MagicBallVisualState();
}

class _MagicBallVisualState extends State<_MagicBallVisual>
    with SingleTickerProviderStateMixin {
  /// Один непрерывный тикер на всё время жизни экрана — приводит и вращение
  /// кольца энергии, и "дыхание" затемнения во время isAsking. Дешевле и
  /// плавнее, чем отдельные AnimationController на каждый жест, и не нужно
  /// стартовать/останавливать его вручную по isAsking (вне isAsking его
  /// значение просто не используется, см. build()).
  late final AnimationController _ticker;

  /// Окошко на картинке шара занимает примерно центральные 44% ширины,
  /// чуть выше геометрического центра — подобрано вручную по пиксельным
  /// координатам assets/images/icons/magic_ball.webp (окошко в оригинале
  /// ~x:280-800, y:280-680 из 1024×1024).
  static const Alignment _windowAlignment = Alignment(0.0, -0.08);
  static const double _windowWidthFraction = 0.42;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAsking = widget.isAsking;
    final String? answerText = widget.answerText;
    final double shakeIntensity = widget.shakeIntensity;

    final double baseGlow = isAsking ? 28.0 : 14.0 + shakeIntensity * 10.0;
    final bool showAnswer = !isAsking && answerText != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ticker,
        builder: (context, child) {
          // "Дыхание" (0..1..0, плавная синусоида) — лёгкая пульсация шара
          // и кольца энергии, пока он "думает". Вне isAsking просто 0 —
          // никакого резкого рывка при появлении/исчезновении.
          final double breath =
              isAsking ? (0.5 + 0.5 * math.sin(_ticker.value * 2 * math.pi)) : 0.0;
          final double scale =
              1.0 + (isAsking ? 0.04 * breath : shakeIntensity * 0.08);
          final double glow = baseGlow + (isAsking ? 10.0 * breath : 0.0);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: AppDimens.magicBallSize,
              height: AppDimens.magicBallSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softGold
                        .withValues(alpha: 0.25 + shakeIntensity * 0.25),
                    blurRadius: glow,
                    spreadRadius: isAsking ? 4 : 0,
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Подложка под прозрачные края картинки шара — тот же
                  // основной синий, что и фон экрана, чтобы не было ни
                  // белых, ни случайных краевых артефактов.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  // Вращающееся кольцо энергии, пока шар "думает" — заметно
                  // мягче и "живее" плоского затемнения.
                  AnimatedOpacity(
                    opacity: isAsking ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: Transform.rotate(
                      angle: _ticker.value * 2 * math.pi,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppColors.turquoise.withValues(alpha: 0.0),
                              AppColors.turquoise.withValues(alpha: 0.55),
                              AppColors.softGold.withValues(alpha: 0.55),
                              AppColors.turquoise.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.35, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Image.asset('assets/images/icons/magic_ball.webp'),
                  // Мягкое радиальное затемнение поверх шара, пока "думает"
                  // — плотнее к краям, светлее к центру (вместо плоской
                  // чёрной заливки), плюс лёгкая пульсация вместе с
                  // "дыханием" кольца энергии.
                  AnimatedOpacity(
                    opacity: isAsking ? 0.55 + 0.25 * breath : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black,
                          ],
                          stops: [0.25, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Ответ светится белым "изнутри" стеклянного окошка —
                  // размер чуть уменьшен, чтобы не выглядел перегруженно на
                  // маленькой площади окошка.
                  Align(
                    alignment: _windowAlignment,
                    child: FractionallySizedBox(
                      widthFactor: _windowWidthFraction,
                      child: AnimatedOpacity(
                        opacity: showAnswer ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                        child: Text(
                          answerText ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            shadows: const [
                              Shadow(color: Colors.white, blurRadius: 10),
                              Shadow(color: AppColors.turquoise, blurRadius: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Блок "заблокировано" — текст причины + кнопка перехода (Paywall/карта
/// локаций), см. задание Этапа 5, пункт F.
class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: AppColors.softGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 12),
          NeumorphicButton(label: buttonLabel, onPressed: onPressed),
        ],
      ),
    );
  }
}
