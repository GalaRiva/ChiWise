import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

/// Экран авторизации — Apple / Google / «Продолжить без регистрации».
/// См. FLUTTER_ARCHITECTURE_PLAN.md, Этап 1.
///
/// Навигация дальше (на карту локаций) происходит не через явную навигацию,
/// а через redirect в go_router: как только authNotifierProvider переходит в
/// AuthStateAuthenticated, appRouterProvider пересобирается и redirect уводит
/// пользователя на homeMap (см. core/router/app_router.dart).
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  void _handleProvider(WidgetRef ref, AuthProviderType provider) {
    final AuthState current = ref.read(authNotifierProvider);
    final AuthNotifier notifier = ref.read(authNotifierProvider.notifier);

    // Защитный случай: если пользователь уже вошёл анонимно (в норме экран
    // авторизации недостижим после входа — см. redirect в app_router.dart),
    // привязываем провайдер к текущему аккаунту вместо повторного signIn,
    // чтобы не потерять данные (требование ТЗ, см. AuthRepository).
    if (current is AuthStateAuthenticated &&
        current.provider == AuthProviderType.anonymous &&
        provider != AuthProviderType.anonymous) {
      notifier.linkAccount(provider);
      return;
    }

    switch (provider) {
      case AuthProviderType.google:
        notifier.signInWithGoogle();
        break;
      case AuthProviderType.apple:
        notifier.signInWithApple();
        break;
      case AuthProviderType.anonymous:
        notifier.signInAnonymously();
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AuthState authState = ref.watch(authNotifierProvider);
    final bool isBusy = authState is AuthStateAuthenticating;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: 48),
              _AuthButton(
                icon: Icons.apple,
                label: l10n.authContinueWithApple,
                onPressed: isBusy
                    ? null
                    : () => _handleProvider(ref, AuthProviderType.apple),
              ),
              const SizedBox(height: 16),
              _AuthButton(
                // TODO(полировка): заменить на брендовую SVG-иконку Google —
                // Material Icons не содержит официального логотипа Google.
                icon: Icons.g_mobiledata,
                label: l10n.authContinueWithGoogle,
                onPressed: isBusy
                    ? null
                    : () => _handleProvider(ref, AuthProviderType.google),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isBusy
                    ? null
                    : () => _handleProvider(ref, AuthProviderType.anonymous),
                child: Text(
                  l10n.authContinueAnonymously,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
              if (isBusy) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(color: AppColors.turquoise),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка входа с иконкой провайдера — единый стиль темы
/// (ElevatedButtonTheme, см. core/theme/app_theme.dart: скруглённые углы,
/// заливка цветом акцента). Детальный neumorphism — задача будущего этапа.
class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
