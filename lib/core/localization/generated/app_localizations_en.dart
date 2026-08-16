// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chi Wise Magic';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingTitle1 => 'We often face difficult decisions';

  @override
  String get onboardingTitle2 =>
      'Sometimes fear holds us back! Emotions cloud the mind!';

  @override
  String get onboardingTitle3 =>
      'Sometimes an important decision must be made quickly, but it\'s hard to do';

  @override
  String get onboardingTitle4 =>
      'Make conscious decisions you\'ll never feel guilty or regretful about';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueAnonymously => 'Continue without an account';

  @override
  String get decisionDoubtPrompt =>
      'If you don\'t know what to do... write down your doubt';

  @override
  String get decisionQuestion1 => 'What will happen if it does?';

  @override
  String get decisionQuestion2 => 'What will happen if it doesn\'t?';

  @override
  String get decisionQuestion3 => 'What won\'t happen if it does?';

  @override
  String get decisionQuestion4 => 'What won\'t happen if it doesn\'t?';

  @override
  String get decisionMyDecisionLabel => 'My decision';

  @override
  String get decisionMyDecisionHint => 'Write down what you\'ve decided to do';

  @override
  String get decisionNext => 'Next';

  @override
  String get decisionBack => 'Back';

  @override
  String get decisionCancel => 'Cancel';

  @override
  String get decisionAccept => 'Decision made';

  @override
  String get decisionCancelConfirmTitle => 'Cancel this entry?';

  @override
  String get decisionCancelConfirmMessage =>
      'The draft will be deleted and can\'t be recovered.';

  @override
  String get decisionCancelConfirmYes => 'Yes, cancel';

  @override
  String get decisionCancelConfirmNo => 'Keep going';

  @override
  String get decisionSummaryTitle => 'Your Decision';

  @override
  String get decisionSummarySubtitle =>
      'Review your answers and decide with clarity';

  @override
  String get decisionDetailSave => 'Save';

  @override
  String get decisionDetailSaved => 'Changes saved';

  @override
  String get decisionDetailNotFound => 'Entry not found';

  @override
  String get magicBallAsk => 'Ask the ball';

  @override
  String get magicBallReturn => 'Return';

  @override
  String get magicBallWarning =>
      'Please be respectful to the Magic Ball and phrase your questions clearly. Focus on your question. Be sincere.';

  @override
  String get magicBallShakeHint => 'Tap the ball or shake your phone';

  @override
  String get magicBallLimitReachedMessage =>
      'You\'ve used all your free questions to the Ball. Get unlimited access to keep asking.';

  @override
  String get magicBallGoToPaywall => 'Get unlimited access';

  @override
  String get magicBallLowEnergyMessage =>
      'The Ball is tired and can\'t answer. Make a mindful decision on the map to recharge its energy.';

  @override
  String get magicBallGoToDecision => 'Make a decision';

  @override
  String get paywallTitle => 'Get the Magic Ball!';

  @override
  String get paywallSubtitle =>
      'Ask unlimited questions and get instant answers.';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallYearly => 'Yearly';

  @override
  String get paywallLifetime => 'Lifetime';

  @override
  String paywallYearlySavings(String amount) {
    return 'Save $amount!';
  }

  @override
  String get paywallContinue => 'Continue';

  @override
  String get paywallRestoreButton => 'Restore purchases';

  @override
  String get paywallRestoreFailed =>
      'No active purchases were found to restore.';

  @override
  String get paywallPurchaseUnavailable =>
      'Purchases aren\'t available yet — the store isn\'t set up.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get ratingTitle => 'How was your experience?';

  @override
  String get ratingLowStarsThanks =>
      'Thanks for the feedback — tell us more so we can improve';

  @override
  String get ratingHighStarsThanks =>
      'Thank you! Would you rate us on the store?';

  @override
  String get ratingSubmit => 'Submit';

  @override
  String get ratingSkip => 'Not now';

  @override
  String get ratingDone => 'Done';

  @override
  String get ratingEmailSubject => 'Feedback about Chi Wise Magic';

  @override
  String get ratingEmailBody => 'Tell us what we could improve:';

  @override
  String get achOrbitalStabilityTitle => 'Orbital Stability';

  @override
  String get achOrbitalStabilityDesc =>
      'Make at least one decision every day for 7 days in a row.';

  @override
  String get achNightOwlSageTitle => 'Night Owl Sage';

  @override
  String get achNightOwlSageDesc =>
      'Complete the Square and make a decision after 11pm.';

  @override
  String get achBalanceMasterTitle => 'Balance Master';

  @override
  String get achBalanceMasterDesc =>
      'Write an equal number of arguments in all four blocks.';

  @override
  String get achDeepAnalysisTitle => 'Deep Analysis';

  @override
  String get achDeepAnalysisDesc =>
      'Write more than 5 detailed points in each block of one doubt.';

  @override
  String get achIllusionBreakerTitle => 'Illusion Breaker';

  @override
  String get achIllusionBreakerDesc =>
      'The hardest block — \"what won\'t happen if it doesn\'t\" — turns out to be the most detailed.';

  @override
  String get achEclipseCatcherTitle => 'Eclipse Catcher';

  @override
  String get achEclipseCatcherDesc =>
      'Resolve a doubt that sat as a draft longer than any other (7+ days).';

  @override
  String get achPlanetParadeTitle => 'Planet Parade';

  @override
  String get achPlanetParadeDesc =>
      'Make 6 decisions in a row within the same category.';

  @override
  String get achLightMindTitle => 'Clear Mind';

  @override
  String get achLightMindDesc =>
      'Move from an earthly location (Mountain/Island) to a cosmic one (Star Peak).';

  @override
  String get achMagicResonanceTitle => 'Magic Resonance';

  @override
  String get achMagicResonanceDesc =>
      'Fully recharge the Ball\'s energy without asking it a single question.';

  @override
  String get achFateTesterTitle => 'Fate Tester';

  @override
  String get achFateTesterDesc =>
      'Ask the Ball 3 different questions in one day.';

  @override
  String get achEclipseObserverTitle => 'Eclipse Observer';

  @override
  String get achEclipseObserverRiddle =>
      'Sometimes you must climb to see how the shadow briefly covers the light. Find your peak.';

  @override
  String get achEclipseObserverDesc =>
      'Left a doubt as a draft for several days, then returned and made a clear decision.';

  @override
  String get achEclipseObserverQuote =>
      'Even the sun returns after its shadow passes.';

  @override
  String get achPerfectAlignmentTitle => 'Perfect Alignment';

  @override
  String get achPerfectAlignmentRiddle =>
      'A rare event, when six spheres line up as one. Bring your thoughts into the same order.';

  @override
  String get achPerfectAlignmentDesc =>
      '6 decisions in a row with the same tag, without asking the Magic Ball once.';

  @override
  String get achPerfectAlignmentQuote => 'Clarity is a line, not a scatter.';

  @override
  String get achOrhekiaHeightTitle => 'Height of Orhekia';

  @override
  String get achOrhekiaHeightRiddle =>
      'The higher the viewpoint, the clearer the horizon. Clear away every obstacle in your path.';

  @override
  String get achOrhekiaHeightDesc =>
      'Filled all four blocks of the Square without a single backspace/delete.';

  @override
  String get achOrhekiaHeightQuote => 'One breath, one thought, one truth.';

  @override
  String get achOracleWhisperTitle => 'Whisper of the Oracle';

  @override
  String get achOracleWhisperRiddle =>
      'The Ball knows the answer, but sometimes needs time to think. Shake it, but don\'t rush it.';

  @override
  String get achOracleWhisperDesc =>
      'Held the Ball shaking for 15+ seconds on the Magic Ball screen without pressing \"Ask\".';

  @override
  String get achOracleWhisperQuote =>
      'Patience is a question asked without words.';

  @override
  String get locationRiverField => 'River and Field';

  @override
  String get locationMountain => 'Mountain';

  @override
  String get locationStarPeak => 'Star Peak';

  @override
  String get locationIsland => 'Island';

  @override
  String get locationOceanBoat => 'Ocean by Boat';

  @override
  String get locationOracleValley => 'Oracle Valley';

  @override
  String get locationEclipseGate => 'Eclipse Gate';

  @override
  String get locationSixPlanetsPath => 'Path of Six Planets';

  @override
  String get locationSolarSystem => 'Solar System';

  @override
  String get locationConstellations => 'Constellations';

  @override
  String get locationMilkyWay => 'Milky Way Galaxy';

  @override
  String get locationLargestGalaxy => 'The Largest Known Galaxy';

  @override
  String get locationUniverse => 'Image of the Universe';

  @override
  String get locationHumanBrain => 'Human Brain';

  @override
  String get locationHomeOutside => 'Home (Outside)';

  @override
  String get locationHomeInsideFinal => 'Home (Inside)';

  @override
  String homeMapDecisionsCount(int count) {
    return 'Decisions made: $count';
  }

  @override
  String homeMapStreak(int count) {
    return 'Day streak: $count';
  }

  @override
  String get homeMapStartDecision => 'Make a decision';

  @override
  String get homeMapLocationLocked => 'This location is still locked';

  @override
  String get homeMapDecisionsHereTitle => 'Decisions here';

  @override
  String get homeMapNoDecisionsHere => 'No decisions here yet';

  @override
  String get achievementsScreenTitle => 'Achievements';

  @override
  String get achievementsCategoryBehavioral => 'Behavioral';

  @override
  String get achievementsCategoryAnalytical => 'Analytical';

  @override
  String get achievementsCategoryNarrativeAstro => 'Story & Cosmos';

  @override
  String get achievementsCategoryMagicBall => 'Magic Ball';

  @override
  String get mindfulnessScreenTitle => 'Mindfulness Scale';

  @override
  String get mindfulnessLevelSeeker => 'Seeker';

  @override
  String get mindfulnessLevelObserver => 'Observer';

  @override
  String get mindfulnessLevelRationalist => 'Rationalist';

  @override
  String get mindfulnessLevelBalanceMaster => 'Balance Master';

  @override
  String get mindfulnessLevelGuardianOfClarity => 'Guardian of Clarity';

  @override
  String mindfulnessScoreLabel(int score) {
    return '$score mindfulness points';
  }

  @override
  String mindfulnessProgressToNext(int percent) {
    return 'To the next level: $percent%';
  }

  @override
  String get mindfulnessMaxLevelReached =>
      'You\'ve reached the peak of mindfulness';

  @override
  String mindfulnessLevelUpMessage(String level) {
    return 'New level: $level!';
  }

  @override
  String get decisionTagWork => 'Work';

  @override
  String get decisionTagRelationships => 'Relationships';

  @override
  String get decisionTagHealth => 'Health';

  @override
  String get decisionTagFinances => 'Finances';

  @override
  String get decisionTagPersonalGrowth => 'Personal Growth';

  @override
  String get decisionTagOther => 'Other';

  @override
  String get decisionTagPickerLabel => 'Category (optional)';

  @override
  String get statsScreenTitle => 'My Decisions';

  @override
  String get statsEmptyState =>
      'No completed decisions yet — make your first one to see your stats';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsSubscriptionNone => 'No active subscription';

  @override
  String settingsSubscriptionExpiresOn(String date) {
    return 'Active until $date';
  }

  @override
  String get settingsUpgradeButton => 'Get Premium';

  @override
  String get settingsLanguageSystemDefault => 'System default';
}
