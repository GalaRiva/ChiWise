import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import 'user_profile_provider.dart';

/// Вехи (кол-во завершённых решений `UserModel.decisionsCount`), на которых
/// показывается кастомный экран оценки приложения (Этап 7, см. ТЗ и задание
/// Этапа 7). Показывается РОВНО дважды за всё время использования
/// приложения — см. [shouldShowRatingPrompt].
const List<int> kRatingPromptMilestones = [3, 10];

/// Email поддержки — зафиксирован в ТЗ, используется в
/// `ReviewService.openSupportEmail` (см. services/review_service.dart) как
/// адрес письма для оценок 1-3 звезды.
const String kSupportEmail = 'egorova.esp@gmail.com';

/// Чистая функция без побочных эффектов — решает, нужно ли показать экран
/// оценки СЕЙЧАС, сразу после завершения решения (см.
/// decision_summary_screen.dart, `_acceptDecision()`). `true`, если текущее
/// `decisionsCount` совпадает с одной из [kRatingPromptMilestones] И эта
/// веха ещё не была показана (её нет в `user.ratingPromptsShown`).
bool shouldShowRatingPrompt(UserModel user) {
  return kRatingPromptMilestones.contains(user.decisionsCount) &&
      !user.ratingPromptsShown.contains(user.decisionsCount);
}

/// Ищет среди [kRatingPromptMilestones] веху, которая ещё не показана
/// пользователю (нет в `user.ratingPromptsShown`) — используется экраном
/// оценки (см. rating_screen.dart), чтобы узнать, какую именно веху он
/// подтверждает после выбора звёзд/пропуска. `null`, если подходящей вехи
/// не нашлось (напр. экран открыли напрямую, а не из
/// `decision_summary_screen.dart` сразу после [shouldShowRatingPrompt]).
int? pendingRatingMilestone(UserModel user) {
  for (final int milestone in kRatingPromptMilestones) {
    if (!user.ratingPromptsShown.contains(milestone)) return milestone;
  }
  return null;
}

/// Riverpod-нотифаер экрана оценки приложения (Этап 7). Presentation-слой
/// (RatingScreen) вызывает только метод [markPromptShown] — тот же стиль,
/// что и MagicBallNotifier/PaywallNotifier (см. magic_ball_provider.dart,
/// paywall_provider.dart). Собственного состояния (звёзды, isSubmitting)
/// этот нотифаер не хранит — простая логика звёзд живёт прямо в
/// `RatingScreen` через локальный `State` (см. задание Этапа 7, пункт 1,
/// "опционально" — так проще и не плодит лишний Riverpod-стейт ради UI).
class RatingFlowNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Помечает [milestone] как показанный — добавляет его в
  /// `user.ratingPromptsShown` и сохраняет профиль через
  /// `UserProfileNotifier.updateProfile` (новых методов в
  /// user_profile_provider.dart не добавляем, см. задание Этапа 7, пункт 1).
  Future<void> markPromptShown(int milestone) async {
    await ref.read(userProfileProvider.notifier).updateProfile(
          (current) => current.copyWith(
            ratingPromptsShown: [...current.ratingPromptsShown, milestone],
          ),
        );
  }
}

final NotifierProvider<RatingFlowNotifier, void> ratingFlowProvider =
    NotifierProvider<RatingFlowNotifier, void>(RatingFlowNotifier.new);
