import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/decision_repository_impl.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/usecases/auth/delete_account.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';

/// Usecase-провайдер для этого экрана — по аналогии с
/// completeDecisionUseCaseProvider в decision_summary_screen.dart (не в
/// auth_provider.dart, т.к. зависит ещё и от User-/DecisionRepository, не
/// только от AuthRepository).
final Provider<DeleteAccount> deleteAccountUseCaseProvider =
    Provider<DeleteAccount>((ref) {
  return DeleteAccount(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(decisionRepositoryProvider),
  );
});

/// Экран «Настройки» (маршрут `AppRoutes.settings`, Этап 11) — переключатель
/// языка интерфейса (см. presentation/providers/locale_provider.dart),
/// отображение статуса подписки и удаление аккаунта (требование Google Play
/// для приложений с регистрацией — см. фидбэк).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDeleting = false;

  Future<void> _confirmAndDeleteAccount(AppLocalizations l10n) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        title: Text(
          l10n.settingsDeleteAccountConfirmTitle,
          style: AppTextStyles.titleMedium,
        ),
        content: Text(
          l10n.settingsDeleteAccountConfirmMessage,
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.settingsDeleteAccountConfirmNo,
              style: AppTextStyles.bodySecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.settingsDeleteAccountConfirmYes,
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.waveformChaotic),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || _isDeleting) return;

    final AuthState authState = ref.read(authNotifierProvider);
    final String? uid =
        authState is AuthStateAuthenticated ? authState.uid : null;
    if (uid == null) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteAccountUseCaseProvider).call(uid);
      // Успех: FirebaseAuth.currentUser стал null -> authStateChanges()
      // эмитит null -> AuthNotifier обновляет state -> redirect в
      // app_router.dart сам уводит на /auth. Ничего навигировать вручную
      // не нужно.
    } catch (_) {
      // Самый вероятный случай — `requires-recent-login` (Firebase требует
      // свежую сессию для удаления аккаунта), но конкретный код тут не
      // важен: сообщение одно и то же — попросить войти заново.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsDeleteAccountError)),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  /// Названия языков традиционно показывают на самом языке, а не переводят,
  /// поэтому статическая карта вместо обращения к l10n.
  static const Map<String, String> _languageNames = {
    'ru': 'Русский',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'pt': 'Português',
  };

  String _formatDate(DateTime d) {
    final String day = d.day.toString().padLeft(2, '0');
    final String month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }

  String _subscriptionName(AppLocalizations l10n, SubscriptionType type) {
    switch (type) {
      case SubscriptionType.monthly:
        return l10n.paywallMonthly;
      case SubscriptionType.yearly:
        return l10n.paywallYearly;
      case SubscriptionType.lifetime:
        return l10n.paywallLifetime;
      case SubscriptionType.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale? selectedLocale = ref.watch(localeProvider);
    final UserModel? user = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.settingsScreenTitle, style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            8,
            AppDimens.screenPadding,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsLanguage, style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _LanguageOptionCard(
                name: l10n.settingsLanguageSystemDefault,
                selected: selectedLocale == null,
                onTap: () => ref.read(localeProvider.notifier).setLocale(null),
              ),
              const SizedBox(height: 12),
              for (final String code in kSupportedLocaleCodes) ...[
                _LanguageOptionCard(
                  name: _languageNames[code] ?? code,
                  selected: selectedLocale?.languageCode == code,
                  onTap: () => ref.read(localeProvider.notifier).setLocale(code),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              Text(l10n.settingsSubscription, style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              if (user == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(color: AppColors.softGold),
                  ),
                )
              else
                _buildSubscriptionSection(context, l10n, user),
              const SizedBox(height: 20),
              Text(l10n.settingsAccountSection, style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _DangerButton(
                label: l10n.settingsDeleteAccountButton,
                isLoading: _isDeleting,
                onPressed:
                    _isDeleting ? null : () => _confirmAndDeleteAccount(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(
    BuildContext context,
    AppLocalizations l10n,
    UserModel user,
  ) {
    if (!user.isSubscribed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsSubscriptionNone, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            NeumorphicButton(
              label: l10n.settingsUpgradeButton,
              onPressed: () => context.push(AppRoutes.paywall),
            ),
          ],
        ),
      );
    }

    final String planName = _subscriptionName(l10n, user.subscriptionType);
    final DateTime? expiresAt = user.subscriptionExpiresAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: AppColors.softGold, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(planName, style: AppTextStyles.bodyMedium),
                if (expiresAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.settingsSubscriptionExpiresOn(_formatDate(expiresAt)),
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Кнопка деструктивного действия — та же неоморфная база, что и
/// NeumorphicButton, но с акцентным (не общим) цветом текста и опциональным
/// спиннером вместо подписи. Не расширяем сам NeumorphicButton ради одной
/// кнопки на весь экран.
class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        border: Border.all(color: AppColors.waveformChaotic.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.waveformChaotic,
                      ),
                    )
                  : Text(
                      label,
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.waveformChaotic),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Карточка одной опции языка — тот же стиль, что и `_MindfulnessLevelCard`
/// в mindfulness_screen.dart (Container с AppColors.surface/cardRadius +
/// иконка check_circle/radio_button_unchecked справа).
class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: selected
                    ? AppTextStyles.bodyMedium
                    : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.softGold : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
