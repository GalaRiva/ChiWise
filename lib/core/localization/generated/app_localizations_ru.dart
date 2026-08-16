// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Chi Wise Magic';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingTitle1 => 'Часто сталкиваемся со сложными решениями';

  @override
  String get onboardingTitle2 =>
      'Иногда страхи останавливают! Эмоции застилают разум!';

  @override
  String get onboardingTitle3 =>
      'Иногда важное решение надо принять быстро, но сделать это сложно';

  @override
  String get onboardingTitle4 =>
      'Принимай осознанные решения, за которые не будешь чувствовать вину и сожаления';

  @override
  String get authContinueWithApple => 'Войти через Apple';

  @override
  String get authContinueWithGoogle => 'Войти через Google';

  @override
  String get authContinueAnonymously => 'Продолжить без регистрации';

  @override
  String get decisionDoubtPrompt =>
      'Если не знаешь, как поступить... напишите своё сомнение';

  @override
  String get decisionQuestion1 => 'Что будет, если это произойдёт?';

  @override
  String get decisionQuestion2 => 'Что будет, если это НЕ произойдёт?';

  @override
  String get decisionQuestion3 => 'Чего НЕ будет, если это произойдёт?';

  @override
  String get decisionQuestion4 => 'Чего НЕ будет, если это НЕ произойдёт?';

  @override
  String get decisionMyDecisionLabel => 'Моё решение';

  @override
  String get decisionMyDecisionHint => 'Напишите, как вы решили поступить';

  @override
  String get decisionNext => 'Далее';

  @override
  String get decisionBack => 'Назад';

  @override
  String get decisionCancel => 'Отменить';

  @override
  String get decisionAccept => 'Решение принято';

  @override
  String get decisionCancelConfirmTitle => 'Отменить заполнение?';

  @override
  String get decisionCancelConfirmMessage =>
      'Черновик сомнения будет удалён без возможности восстановления.';

  @override
  String get decisionCancelConfirmYes => 'Да, отменить';

  @override
  String get decisionCancelConfirmNo => 'Продолжить';

  @override
  String get decisionSummaryTitle => 'Твоё решение';

  @override
  String get decisionSummarySubtitle =>
      'Просмотри свои ответы и прими решение осознанно';

  @override
  String get decisionDetailSave => 'Сохранить';

  @override
  String get decisionDetailSaved => 'Изменения сохранены';

  @override
  String get decisionDetailNotFound => 'Запись не найдена';

  @override
  String get magicBallAsk => 'Спросить шар';

  @override
  String get magicBallReturn => 'Вернуться';

  @override
  String get magicBallWarning =>
      'Проявляйте уважение к Магическому шару и ясно формулируйте свои вопросы. Сконцентрируйтесь на вопросе. Будьте искренним.';

  @override
  String get magicBallShakeHint => 'Нажми на шар или тряхни телефон';

  @override
  String get magicBallLimitReachedMessage =>
      'Бесплатные вопросы Шару закончились. Оформи подписку, чтобы спрашивать без ограничений.';

  @override
  String get magicBallGoToPaywall => 'Получить безлимитный доступ';

  @override
  String get magicBallLowEnergyMessage =>
      'Шар устал и не может ответить. Прими осознанное решение на карте локаций, чтобы зарядить его энергию.';

  @override
  String get magicBallGoToDecision => 'Принять решение';

  @override
  String get paywallTitle => 'Получить Магический Шар!';

  @override
  String get paywallSubtitle =>
      'Задавай неограниченное количество вопросов и получай немедленный ответ.';

  @override
  String get paywallMonthly => 'Месяц';

  @override
  String get paywallYearly => 'Год';

  @override
  String get paywallLifetime => 'Навсегда';

  @override
  String paywallYearlySavings(String amount) {
    return 'Сэкономишь $amount!';
  }

  @override
  String get paywallContinue => 'Продолжить';

  @override
  String get paywallRestoreButton => 'Восстановить покупки';

  @override
  String get paywallRestoreFailed =>
      'Не удалось найти активные покупки для восстановления.';

  @override
  String get paywallPurchaseUnavailable =>
      'Покупки пока недоступны — магазин ещё не настроен.';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsSubscription => 'Подписка';

  @override
  String get ratingTitle => 'Как вам приложение?';

  @override
  String get ratingLowStarsThanks =>
      'Спасибо за отзыв — расскажите подробнее, чтобы мы стали лучше';

  @override
  String get ratingHighStarsThanks => 'Спасибо! Оцените нас в сторе?';

  @override
  String get ratingSubmit => 'Отправить';

  @override
  String get ratingSkip => 'Позже';

  @override
  String get ratingDone => 'Готово';

  @override
  String get ratingEmailSubject => 'Отзыв о Chi Wise Magic';

  @override
  String get ratingEmailBody => 'Расскажите, что можно улучшить:';

  @override
  String get achOrbitalStabilityTitle => 'Орбитальная стабильность';

  @override
  String get achOrbitalStabilityDesc =>
      'Принимать хотя бы одно решение 7 дней подряд.';

  @override
  String get achNightOwlSageTitle => 'Сова-мудрец';

  @override
  String get achNightOwlSageDesc =>
      'Заполнить квадрат и принять решение после 23:00.';

  @override
  String get achBalanceMasterTitle => 'Мастер баланса';

  @override
  String get achBalanceMasterDesc =>
      'Написать равное количество аргументов во всех четырёх квадратах.';

  @override
  String get achDeepAnalysisTitle => 'Глубокий анализ';

  @override
  String get achDeepAnalysisDesc =>
      'Заполнить более 5 развёрнутых пунктов в каждом из блоков одного сомнения.';

  @override
  String get achIllusionBreakerTitle => 'Разрушитель иллюзий';

  @override
  String get achIllusionBreakerDesc =>
      'Блок «Чего НЕ будет, если это НЕ произойдёт» оказался самым заполненным.';

  @override
  String get achEclipseCatcherTitle => 'Ловец затмений';

  @override
  String get achEclipseCatcherDesc =>
      'Решение проблемы, которая «висела» в черновиках дольше всего (7+ дней).';

  @override
  String get achPlanetParadeTitle => 'Парад планет';

  @override
  String get achPlanetParadeDesc =>
      '6 решений подряд в одной и той же категории.';

  @override
  String get achLightMindTitle => 'Светлый разум';

  @override
  String get achLightMindDesc =>
      'Переход с земных локаций (Гора/Остров) на космические (Звёздный пик).';

  @override
  String get achMagicResonanceTitle => 'Магический резонанс';

  @override
  String get achMagicResonanceDesc =>
      'Полностью зарядить энергию Шара, ни разу не обратившись к нему за подсказкой.';

  @override
  String get achFateTesterTitle => 'Испытатель судьбы';

  @override
  String get achFateTesterDesc =>
      'Использовать Шар 3 раза за один день для разных вопросов.';

  @override
  String get achEclipseObserverTitle => 'Наблюдатель Затмения';

  @override
  String get achEclipseObserverRiddle =>
      'Иногда нужно подняться на возвышенность, чтобы увидеть, как тень ненадолго закрывает свет. Найди свой пик.';

  @override
  String get achEclipseObserverDesc =>
      'Сомнение оставалось черновиком несколько дней, а затем было принято чёткое решение.';

  @override
  String get achEclipseObserverQuote =>
      'Даже солнце возвращается, когда тень проходит.';

  @override
  String get achPerfectAlignmentTitle => 'Идеальное Выравнивание';

  @override
  String get achPerfectAlignmentRiddle =>
      'Редчайшее событие, когда шесть сфер выстраиваются в одну линию. Приведи мысли в такой же порядок.';

  @override
  String get achPerfectAlignmentDesc =>
      '6 решений подряд в одной категории без единого обращения к Магическому Шару.';

  @override
  String get achPerfectAlignmentQuote => 'Ясность — это линия, а не разброс.';

  @override
  String get achOrhekiaHeightTitle => 'Высота Орхехии';

  @override
  String get achOrhekiaHeightRiddle =>
      'Чем выше точка обзора, тем яснее горизонт. Избавься от всех помех на своём пути.';

  @override
  String get achOrhekiaHeightDesc =>
      'Заполнены все четыре блока Квадрата Декарта без единого backspace.';

  @override
  String get achOrhekiaHeightQuote => 'Один вдох, одна мысль, одна правда.';

  @override
  String get achOracleWhisperTitle => 'Шёпот Оракула';

  @override
  String get achOracleWhisperRiddle =>
      'Шар знает ответ, но иногда ему нужно время на раздумья. Потряси, но не торопи.';

  @override
  String get achOracleWhisperDesc =>
      'Тряска Шара на экране удерживалась 15+ секунд без нажатия «Спросить».';

  @override
  String get achOracleWhisperQuote =>
      'Терпение — это вопрос, заданный без слов.';

  @override
  String get locationRiverField => 'Река и поле';

  @override
  String get locationMountain => 'Гора';

  @override
  String get locationStarPeak => 'Звёздный пик';

  @override
  String get locationIsland => 'Остров';

  @override
  String get locationOceanBoat => 'Океан на лодке';

  @override
  String get locationOracleValley => 'Долина Оракула';

  @override
  String get locationEclipseGate => 'Врата Затмения';

  @override
  String get locationSixPlanetsPath => 'Тропа Шести Планет';

  @override
  String get locationSolarSystem => 'Солнечная система';

  @override
  String get locationConstellations => 'Созвездия';

  @override
  String get locationMilkyWay => 'Галактика Млечный Путь';

  @override
  String get locationLargestGalaxy => 'Самая большая известная галактика';

  @override
  String get locationUniverse => 'Изображение вселенной';

  @override
  String get locationHumanBrain => 'Мозг человека';

  @override
  String get locationHomeOutside => 'Дом (Снаружи)';

  @override
  String get locationHomeInsideFinal => 'Дом (Внутри)';

  @override
  String homeMapDecisionsCount(int count) {
    return 'Решений принято: $count';
  }

  @override
  String homeMapStreak(int count) {
    return 'Серия дней: $count';
  }

  @override
  String get homeMapStartDecision => 'Принять решение';

  @override
  String get homeMapLocationLocked => 'Эта локация ещё закрыта';

  @override
  String get homeMapDecisionsHereTitle => 'Решения здесь';

  @override
  String get homeMapNoDecisionsHere => 'Пока нет решений на этой локации';

  @override
  String get achievementsScreenTitle => 'Достижения';

  @override
  String get achievementsCategoryBehavioral => 'Поведенческие';

  @override
  String get achievementsCategoryAnalytical => 'Аналитические';

  @override
  String get achievementsCategoryNarrativeAstro => 'Сюжетные';

  @override
  String get achievementsCategoryMagicBall => 'Магический Шар';

  @override
  String get mindfulnessScreenTitle => 'Шкала осознанности';

  @override
  String get mindfulnessLevelSeeker => 'Искатель';

  @override
  String get mindfulnessLevelObserver => 'Наблюдатель';

  @override
  String get mindfulnessLevelRationalist => 'Рационализатор';

  @override
  String get mindfulnessLevelBalanceMaster => 'Мастер Баланса';

  @override
  String get mindfulnessLevelGuardianOfClarity => 'Хранитель Ясности';

  @override
  String mindfulnessScoreLabel(int score) {
    return '$score очков осознанности';
  }

  @override
  String mindfulnessProgressToNext(int percent) {
    return 'До следующего уровня: $percent%';
  }

  @override
  String get mindfulnessMaxLevelReached => 'Ты достиг вершины осознанности';

  @override
  String mindfulnessLevelUpMessage(String level) {
    return 'Новый уровень: $level!';
  }

  @override
  String get decisionTagWork => 'Работа';

  @override
  String get decisionTagRelationships => 'Отношения';

  @override
  String get decisionTagHealth => 'Здоровье';

  @override
  String get decisionTagFinances => 'Финансы';

  @override
  String get decisionTagPersonalGrowth => 'Личностный рост';

  @override
  String get decisionTagOther => 'Другое';

  @override
  String get decisionTagPickerLabel => 'Категория (необязательно)';

  @override
  String get statsScreenTitle => 'Мои решения';

  @override
  String get statsEmptyState =>
      'Пока нет завершённых решений — прими своё первое, чтобы увидеть статистику';

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get settingsSubscriptionNone => 'Без подписки';

  @override
  String settingsSubscriptionExpiresOn(String date) {
    return 'Действует до $date';
  }

  @override
  String get settingsUpgradeButton => 'Оформить подписку';

  @override
  String get settingsLanguageSystemDefault => 'Как в системе';
}
