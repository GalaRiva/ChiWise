import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';

/// Экран «Настройки» (маршрут `AppRoutes.settings`, Этап 11) — переключатель
/// языка интерфейса (см. presentation/providers/locale_provider.dart) и
/// отображение статуса подписки. Чисто презентационный экран, тот же стиль,
/// что MindfulnessScreen/AchievementsScreen (Scaffold + AppColors.background +
/// прозрачный AppBar + SafeArea + SingleChildScrollView).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
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
