import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Chi Wise Magic'**
  String get appTitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'We often face difficult decisions'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Sometimes fear holds us back! Emotions cloud the mind!'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Sometimes an important decision must be made quickly, but it\'s hard to do'**
  String get onboardingTitle3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Make conscious decisions you\'ll never feel guilty or regretful about'**
  String get onboardingTitle4;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get authContinueAnonymously;

  /// No description provided for @decisionDoubtPrompt.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t know what to do... write down your doubt'**
  String get decisionDoubtPrompt;

  /// No description provided for @decisionQuestion1.
  ///
  /// In en, this message translates to:
  /// **'What will happen if it does?'**
  String get decisionQuestion1;

  /// No description provided for @decisionQuestion2.
  ///
  /// In en, this message translates to:
  /// **'What will happen if it doesn\'t?'**
  String get decisionQuestion2;

  /// No description provided for @decisionQuestion3.
  ///
  /// In en, this message translates to:
  /// **'What won\'t happen if it does?'**
  String get decisionQuestion3;

  /// No description provided for @decisionQuestion4.
  ///
  /// In en, this message translates to:
  /// **'What won\'t happen if it doesn\'t?'**
  String get decisionQuestion4;

  /// No description provided for @decisionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get decisionNext;

  /// No description provided for @decisionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get decisionBack;

  /// No description provided for @decisionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get decisionCancel;

  /// No description provided for @decisionAccept.
  ///
  /// In en, this message translates to:
  /// **'Decision made'**
  String get decisionAccept;

  /// No description provided for @decisionCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this entry?'**
  String get decisionCancelConfirmTitle;

  /// No description provided for @decisionCancelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The draft will be deleted and can\'t be recovered.'**
  String get decisionCancelConfirmMessage;

  /// No description provided for @decisionCancelConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get decisionCancelConfirmYes;

  /// No description provided for @decisionCancelConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get decisionCancelConfirmNo;

  /// No description provided for @decisionSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Decision'**
  String get decisionSummaryTitle;

  /// No description provided for @decisionSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your answers and decide with clarity'**
  String get decisionSummarySubtitle;

  /// No description provided for @decisionDetailSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get decisionDetailSave;

  /// No description provided for @decisionDetailSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get decisionDetailSaved;

  /// No description provided for @decisionDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Entry not found'**
  String get decisionDetailNotFound;

  /// No description provided for @magicBallAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask the ball'**
  String get magicBallAsk;

  /// No description provided for @magicBallReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get magicBallReturn;

  /// No description provided for @magicBallWarning.
  ///
  /// In en, this message translates to:
  /// **'Please be respectful to the Magic Ball and phrase your questions clearly. Focus on your question. Be sincere.'**
  String get magicBallWarning;

  /// No description provided for @magicBallShakeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the ball or shake your phone'**
  String get magicBallShakeHint;

  /// No description provided for @magicBallLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your free questions to the Ball. Get unlimited access to keep asking.'**
  String get magicBallLimitReachedMessage;

  /// No description provided for @magicBallGoToPaywall.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited access'**
  String get magicBallGoToPaywall;

  /// No description provided for @magicBallLowEnergyMessage.
  ///
  /// In en, this message translates to:
  /// **'The Ball is tired and can\'t answer. Make a mindful decision on the map to recharge its energy.'**
  String get magicBallLowEnergyMessage;

  /// No description provided for @magicBallGoToDecision.
  ///
  /// In en, this message translates to:
  /// **'Make a decision'**
  String get magicBallGoToDecision;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Get the Magic Ball!'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask unlimited questions and get instant answers.'**
  String get paywallSubtitle;

  /// No description provided for @paywallMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// No description provided for @paywallYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get paywallYearly;

  /// No description provided for @paywallLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get paywallLifetime;

  /// No description provided for @paywallYearlySavings.
  ///
  /// In en, this message translates to:
  /// **'Save {amount}!'**
  String paywallYearlySavings(String amount);

  /// No description provided for @paywallContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paywallContinue;

  /// No description provided for @paywallRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestoreButton;

  /// No description provided for @paywallRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'No active purchases were found to restore.'**
  String get paywallRestoreFailed;

  /// No description provided for @paywallPurchaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases aren\'t available yet — the store isn\'t set up.'**
  String get paywallPurchaseUnavailable;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscription;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get ratingTitle;

  /// No description provided for @ratingLowStarsThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the feedback — tell us more so we can improve'**
  String get ratingLowStarsThanks;

  /// No description provided for @ratingHighStarsThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Would you rate us on the store?'**
  String get ratingHighStarsThanks;

  /// No description provided for @ratingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get ratingSubmit;

  /// No description provided for @ratingSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get ratingSkip;

  /// No description provided for @ratingDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ratingDone;

  /// No description provided for @ratingEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Feedback about Chi Wise Magic'**
  String get ratingEmailSubject;

  /// No description provided for @ratingEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us what we could improve:'**
  String get ratingEmailBody;

  /// No description provided for @achOrbitalStabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Orbital Stability'**
  String get achOrbitalStabilityTitle;

  /// No description provided for @achOrbitalStabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Make at least one decision every day for 7 days in a row.'**
  String get achOrbitalStabilityDesc;

  /// No description provided for @achNightOwlSageTitle.
  ///
  /// In en, this message translates to:
  /// **'Night Owl Sage'**
  String get achNightOwlSageTitle;

  /// No description provided for @achNightOwlSageDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete the Square and make a decision after 11pm.'**
  String get achNightOwlSageDesc;

  /// No description provided for @achBalanceMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance Master'**
  String get achBalanceMasterTitle;

  /// No description provided for @achBalanceMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Write an equal number of arguments in all four blocks.'**
  String get achBalanceMasterDesc;

  /// No description provided for @achDeepAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Analysis'**
  String get achDeepAnalysisTitle;

  /// No description provided for @achDeepAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Write more than 5 detailed points in each block of one doubt.'**
  String get achDeepAnalysisDesc;

  /// No description provided for @achIllusionBreakerTitle.
  ///
  /// In en, this message translates to:
  /// **'Illusion Breaker'**
  String get achIllusionBreakerTitle;

  /// No description provided for @achIllusionBreakerDesc.
  ///
  /// In en, this message translates to:
  /// **'The hardest block — \"what won\'t happen if it doesn\'t\" — turns out to be the most detailed.'**
  String get achIllusionBreakerDesc;

  /// No description provided for @achEclipseCatcherTitle.
  ///
  /// In en, this message translates to:
  /// **'Eclipse Catcher'**
  String get achEclipseCatcherTitle;

  /// No description provided for @achEclipseCatcherDesc.
  ///
  /// In en, this message translates to:
  /// **'Resolve a doubt that sat as a draft longer than any other (7+ days).'**
  String get achEclipseCatcherDesc;

  /// No description provided for @achPlanetParadeTitle.
  ///
  /// In en, this message translates to:
  /// **'Planet Parade'**
  String get achPlanetParadeTitle;

  /// No description provided for @achPlanetParadeDesc.
  ///
  /// In en, this message translates to:
  /// **'Make 6 decisions in a row within the same category.'**
  String get achPlanetParadeDesc;

  /// No description provided for @achLightMindTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Mind'**
  String get achLightMindTitle;

  /// No description provided for @achLightMindDesc.
  ///
  /// In en, this message translates to:
  /// **'Move from an earthly location (Mountain/Island) to a cosmic one (Star Peak).'**
  String get achLightMindDesc;

  /// No description provided for @achMagicResonanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Magic Resonance'**
  String get achMagicResonanceTitle;

  /// No description provided for @achMagicResonanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Fully recharge the Ball\'s energy without asking it a single question.'**
  String get achMagicResonanceDesc;

  /// No description provided for @achFateTesterTitle.
  ///
  /// In en, this message translates to:
  /// **'Fate Tester'**
  String get achFateTesterTitle;

  /// No description provided for @achFateTesterDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask the Ball 3 different questions in one day.'**
  String get achFateTesterDesc;

  /// No description provided for @achEclipseObserverTitle.
  ///
  /// In en, this message translates to:
  /// **'Eclipse Observer'**
  String get achEclipseObserverTitle;

  /// No description provided for @achEclipseObserverRiddle.
  ///
  /// In en, this message translates to:
  /// **'Sometimes you must climb to see how the shadow briefly covers the light. Find your peak.'**
  String get achEclipseObserverRiddle;

  /// No description provided for @achEclipseObserverDesc.
  ///
  /// In en, this message translates to:
  /// **'Left a doubt as a draft for several days, then returned and made a clear decision.'**
  String get achEclipseObserverDesc;

  /// No description provided for @achEclipseObserverQuote.
  ///
  /// In en, this message translates to:
  /// **'Even the sun returns after its shadow passes.'**
  String get achEclipseObserverQuote;

  /// No description provided for @achPerfectAlignmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Alignment'**
  String get achPerfectAlignmentTitle;

  /// No description provided for @achPerfectAlignmentRiddle.
  ///
  /// In en, this message translates to:
  /// **'A rare event, when six spheres line up as one. Bring your thoughts into the same order.'**
  String get achPerfectAlignmentRiddle;

  /// No description provided for @achPerfectAlignmentDesc.
  ///
  /// In en, this message translates to:
  /// **'6 decisions in a row with the same tag, without asking the Magic Ball once.'**
  String get achPerfectAlignmentDesc;

  /// No description provided for @achPerfectAlignmentQuote.
  ///
  /// In en, this message translates to:
  /// **'Clarity is a line, not a scatter.'**
  String get achPerfectAlignmentQuote;

  /// No description provided for @achOrhekiaHeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Height of Orhekia'**
  String get achOrhekiaHeightTitle;

  /// No description provided for @achOrhekiaHeightRiddle.
  ///
  /// In en, this message translates to:
  /// **'The higher the viewpoint, the clearer the horizon. Clear away every obstacle in your path.'**
  String get achOrhekiaHeightRiddle;

  /// No description provided for @achOrhekiaHeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Filled all four blocks of the Square without a single backspace/delete.'**
  String get achOrhekiaHeightDesc;

  /// No description provided for @achOrhekiaHeightQuote.
  ///
  /// In en, this message translates to:
  /// **'One breath, one thought, one truth.'**
  String get achOrhekiaHeightQuote;

  /// No description provided for @achOracleWhisperTitle.
  ///
  /// In en, this message translates to:
  /// **'Whisper of the Oracle'**
  String get achOracleWhisperTitle;

  /// No description provided for @achOracleWhisperRiddle.
  ///
  /// In en, this message translates to:
  /// **'The Ball knows the answer, but sometimes needs time to think. Shake it, but don\'t rush it.'**
  String get achOracleWhisperRiddle;

  /// No description provided for @achOracleWhisperDesc.
  ///
  /// In en, this message translates to:
  /// **'Held the Ball shaking for 15+ seconds on the Magic Ball screen without pressing \"Ask\".'**
  String get achOracleWhisperDesc;

  /// No description provided for @achOracleWhisperQuote.
  ///
  /// In en, this message translates to:
  /// **'Patience is a question asked without words.'**
  String get achOracleWhisperQuote;

  /// No description provided for @locationRiverField.
  ///
  /// In en, this message translates to:
  /// **'River and Field'**
  String get locationRiverField;

  /// No description provided for @locationMountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get locationMountain;

  /// No description provided for @locationStarPeak.
  ///
  /// In en, this message translates to:
  /// **'Star Peak'**
  String get locationStarPeak;

  /// No description provided for @locationIsland.
  ///
  /// In en, this message translates to:
  /// **'Island'**
  String get locationIsland;

  /// No description provided for @locationOceanBoat.
  ///
  /// In en, this message translates to:
  /// **'Ocean by Boat'**
  String get locationOceanBoat;

  /// No description provided for @locationOracleValley.
  ///
  /// In en, this message translates to:
  /// **'Oracle Valley'**
  String get locationOracleValley;

  /// No description provided for @locationEclipseGate.
  ///
  /// In en, this message translates to:
  /// **'Eclipse Gate'**
  String get locationEclipseGate;

  /// No description provided for @locationSixPlanetsPath.
  ///
  /// In en, this message translates to:
  /// **'Path of Six Planets'**
  String get locationSixPlanetsPath;

  /// No description provided for @locationSolarSystem.
  ///
  /// In en, this message translates to:
  /// **'Solar System'**
  String get locationSolarSystem;

  /// No description provided for @locationConstellations.
  ///
  /// In en, this message translates to:
  /// **'Constellations'**
  String get locationConstellations;

  /// No description provided for @locationMilkyWay.
  ///
  /// In en, this message translates to:
  /// **'Milky Way Galaxy'**
  String get locationMilkyWay;

  /// No description provided for @locationLargestGalaxy.
  ///
  /// In en, this message translates to:
  /// **'The Largest Known Galaxy'**
  String get locationLargestGalaxy;

  /// No description provided for @locationUniverse.
  ///
  /// In en, this message translates to:
  /// **'Image of the Universe'**
  String get locationUniverse;

  /// No description provided for @locationHumanBrain.
  ///
  /// In en, this message translates to:
  /// **'Human Brain'**
  String get locationHumanBrain;

  /// No description provided for @locationHomeOutside.
  ///
  /// In en, this message translates to:
  /// **'Home (Outside)'**
  String get locationHomeOutside;

  /// No description provided for @locationHomeInsideFinal.
  ///
  /// In en, this message translates to:
  /// **'Home (Inside)'**
  String get locationHomeInsideFinal;

  /// No description provided for @homeMapDecisionsCount.
  ///
  /// In en, this message translates to:
  /// **'Decisions made: {count}'**
  String homeMapDecisionsCount(int count);

  /// No description provided for @homeMapStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak: {count}'**
  String homeMapStreak(int count);

  /// No description provided for @homeMapStartDecision.
  ///
  /// In en, this message translates to:
  /// **'Make a decision'**
  String get homeMapStartDecision;

  /// No description provided for @homeMapLocationLocked.
  ///
  /// In en, this message translates to:
  /// **'This location is still locked'**
  String get homeMapLocationLocked;

  /// No description provided for @homeMapDecisionsHereTitle.
  ///
  /// In en, this message translates to:
  /// **'Decisions here'**
  String get homeMapDecisionsHereTitle;

  /// No description provided for @homeMapNoDecisionsHere.
  ///
  /// In en, this message translates to:
  /// **'No decisions here yet'**
  String get homeMapNoDecisionsHere;

  /// No description provided for @achievementsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsScreenTitle;

  /// No description provided for @achievementsCategoryBehavioral.
  ///
  /// In en, this message translates to:
  /// **'Behavioral'**
  String get achievementsCategoryBehavioral;

  /// No description provided for @achievementsCategoryAnalytical.
  ///
  /// In en, this message translates to:
  /// **'Analytical'**
  String get achievementsCategoryAnalytical;

  /// No description provided for @achievementsCategoryNarrativeAstro.
  ///
  /// In en, this message translates to:
  /// **'Story & Cosmos'**
  String get achievementsCategoryNarrativeAstro;

  /// No description provided for @achievementsCategoryMagicBall.
  ///
  /// In en, this message translates to:
  /// **'Magic Ball'**
  String get achievementsCategoryMagicBall;

  /// No description provided for @mindfulnessScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness Scale'**
  String get mindfulnessScreenTitle;

  /// No description provided for @mindfulnessLevelSeeker.
  ///
  /// In en, this message translates to:
  /// **'Seeker'**
  String get mindfulnessLevelSeeker;

  /// No description provided for @mindfulnessLevelObserver.
  ///
  /// In en, this message translates to:
  /// **'Observer'**
  String get mindfulnessLevelObserver;

  /// No description provided for @mindfulnessLevelRationalist.
  ///
  /// In en, this message translates to:
  /// **'Rationalist'**
  String get mindfulnessLevelRationalist;

  /// No description provided for @mindfulnessLevelBalanceMaster.
  ///
  /// In en, this message translates to:
  /// **'Balance Master'**
  String get mindfulnessLevelBalanceMaster;

  /// No description provided for @mindfulnessLevelGuardianOfClarity.
  ///
  /// In en, this message translates to:
  /// **'Guardian of Clarity'**
  String get mindfulnessLevelGuardianOfClarity;

  /// No description provided for @mindfulnessScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'{score} mindfulness points'**
  String mindfulnessScoreLabel(int score);

  /// No description provided for @mindfulnessProgressToNext.
  ///
  /// In en, this message translates to:
  /// **'To the next level: {percent}%'**
  String mindfulnessProgressToNext(int percent);

  /// No description provided for @mindfulnessMaxLevelReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the peak of mindfulness'**
  String get mindfulnessMaxLevelReached;

  /// No description provided for @mindfulnessLevelUpMessage.
  ///
  /// In en, this message translates to:
  /// **'New level: {level}!'**
  String mindfulnessLevelUpMessage(String level);

  /// No description provided for @decisionTagWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get decisionTagWork;

  /// No description provided for @decisionTagRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get decisionTagRelationships;

  /// No description provided for @decisionTagHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get decisionTagHealth;

  /// No description provided for @decisionTagFinances.
  ///
  /// In en, this message translates to:
  /// **'Finances'**
  String get decisionTagFinances;

  /// No description provided for @decisionTagPersonalGrowth.
  ///
  /// In en, this message translates to:
  /// **'Personal Growth'**
  String get decisionTagPersonalGrowth;

  /// No description provided for @decisionTagOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get decisionTagOther;

  /// No description provided for @decisionTagPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get decisionTagPickerLabel;

  /// No description provided for @statsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Decisions'**
  String get statsScreenTitle;

  /// No description provided for @statsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No completed decisions yet — make your first one to see your stats'**
  String get statsEmptyState;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsSubscriptionNone.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get settingsSubscriptionNone;

  /// No description provided for @settingsSubscriptionExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Active until {date}'**
  String settingsSubscriptionExpiresOn(String date);

  /// No description provided for @settingsUpgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get settingsUpgradeButton;

  /// No description provided for @settingsLanguageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystemDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
