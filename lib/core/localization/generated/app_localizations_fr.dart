// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Chi Wise Magic';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingTitle1 =>
      'Nous sommes souvent confrontés à des décisions difficiles';

  @override
  String get onboardingTitle2 =>
      'Parfois, la peur nous arrête ! Les émotions brouillent l\'esprit !';

  @override
  String get onboardingTitle3 =>
      'Parfois, une décision importante doit être prise rapidement, mais c\'est difficile';

  @override
  String get onboardingTitle4 =>
      'Prends des décisions conscientes dont tu ne ressentiras jamais ni culpabilité ni regret';

  @override
  String get authContinueWithApple => 'Continuer avec Apple';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authContinueAnonymously => 'Continuer sans compte';

  @override
  String get decisionDoubtPrompt =>
      'Si vous ne savez pas quoi faire... écrivez votre doute';

  @override
  String get decisionQuestion1 => 'Que se passera-t-il si cela arrive ?';

  @override
  String get decisionQuestion2 => 'Que se passera-t-il si cela n\'arrive pas ?';

  @override
  String get decisionQuestion3 => 'Que ne se passera-t-il PAS si cela arrive ?';

  @override
  String get decisionQuestion4 =>
      'Que ne se passera-t-il PAS si cela n\'arrive pas ?';

  @override
  String get decisionNext => 'Suivant';

  @override
  String get decisionBack => 'Retour';

  @override
  String get decisionCancel => 'Annuler';

  @override
  String get decisionAccept => 'Décision prise';

  @override
  String get decisionCancelConfirmTitle => 'Annuler cette saisie ?';

  @override
  String get decisionCancelConfirmMessage =>
      'Le brouillon sera supprimé et ne pourra pas être récupéré.';

  @override
  String get decisionCancelConfirmYes => 'Oui, annuler';

  @override
  String get decisionCancelConfirmNo => 'Continuer';

  @override
  String get decisionSummaryTitle => 'Ta décision';

  @override
  String get decisionSummarySubtitle =>
      'Relis tes réponses et décide en toute clarté';

  @override
  String get decisionDetailSave => 'Enregistrer';

  @override
  String get decisionDetailSaved => 'Modifications enregistrées';

  @override
  String get decisionDetailNotFound => 'Entrée introuvable';

  @override
  String get magicBallAsk => 'Interroger la boule';

  @override
  String get magicBallReturn => 'Retour';

  @override
  String get magicBallWarning =>
      'Faites preuve de respect envers la Boule Magique et formulez vos questions clairement. Concentrez-vous sur votre question. Soyez sincère.';

  @override
  String get magicBallShakeHint =>
      'Touchez la boule ou secouez votre téléphone';

  @override
  String get magicBallLimitReachedMessage =>
      'Vous avez utilisé toutes vos questions gratuites à la Boule. Obtenez un accès illimité pour continuer.';

  @override
  String get magicBallGoToPaywall => 'Obtenir un accès illimité';

  @override
  String get magicBallLowEnergyMessage =>
      'La Boule est fatiguée et ne peut pas répondre. Prenez une décision consciente sur la carte pour recharger son énergie.';

  @override
  String get magicBallGoToDecision => 'Prendre une décision';

  @override
  String get paywallTitle => 'Obtenez la Boule Magique !';

  @override
  String get paywallSubtitle =>
      'Posez des questions illimitées et obtenez une réponse immédiate.';

  @override
  String get paywallMonthly => 'Mensuel';

  @override
  String get paywallYearly => 'Annuel';

  @override
  String get paywallLifetime => 'À vie';

  @override
  String paywallYearlySavings(String amount) {
    return 'Économisez $amount !';
  }

  @override
  String get paywallContinue => 'Continuer';

  @override
  String get paywallRestoreButton => 'Restaurer les achats';

  @override
  String get paywallRestoreFailed => 'Aucun achat actif trouvé à restaurer.';

  @override
  String get paywallPurchaseUnavailable =>
      'Les achats ne sont pas encore disponibles : la boutique n\'est pas configurée.';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSubscription => 'Abonnement';

  @override
  String get ratingTitle => 'Comment était votre expérience ?';

  @override
  String get ratingLowStarsThanks =>
      'Merci pour votre retour — dites-nous en plus pour nous améliorer';

  @override
  String get ratingHighStarsThanks =>
      'Merci ! Voulez-vous nous noter sur le store ?';

  @override
  String get ratingSubmit => 'Envoyer';

  @override
  String get ratingSkip => 'Plus tard';

  @override
  String get ratingDone => 'Terminé';

  @override
  String get ratingEmailSubject => 'Avis sur Chi Wise Magic';

  @override
  String get ratingEmailBody => 'Dites-nous ce que nous pourrions améliorer :';

  @override
  String get achOrbitalStabilityTitle => 'Stabilité Orbitale';

  @override
  String get achOrbitalStabilityDesc =>
      'Prends au moins une décision chaque jour pendant 7 jours d\'affilée.';

  @override
  String get achNightOwlSageTitle => 'Sage Oiseau de Nuit';

  @override
  String get achNightOwlSageDesc =>
      'Remplis le Carré et prends une décision après 23h.';

  @override
  String get achBalanceMasterTitle => 'Maître de l\'Équilibre';

  @override
  String get achBalanceMasterDesc =>
      'Écris le même nombre d\'arguments dans les quatre blocs.';

  @override
  String get achDeepAnalysisTitle => 'Analyse Approfondie';

  @override
  String get achDeepAnalysisDesc =>
      'Écris plus de 5 points détaillés dans chaque bloc d\'un même doute.';

  @override
  String get achIllusionBreakerTitle => 'Briseur d\'Illusions';

  @override
  String get achIllusionBreakerDesc =>
      'Le bloc le plus difficile — « ce qui n\'arrivera pas si cela n\'arrive pas » — s\'avère être le plus détaillé.';

  @override
  String get achEclipseCatcherTitle => 'Chasseur d\'Éclipses';

  @override
  String get achEclipseCatcherDesc =>
      'Résous un doute resté en brouillon plus longtemps que tout autre (7+ jours).';

  @override
  String get achPlanetParadeTitle => 'Parade des Planètes';

  @override
  String get achPlanetParadeDesc =>
      'Prends 6 décisions d\'affilée dans la même catégorie.';

  @override
  String get achLightMindTitle => 'Esprit Léger';

  @override
  String get achLightMindDesc =>
      'Passe d\'un lieu terrestre (Montagne/Île) à un lieu cosmique (Pic Stellaire).';

  @override
  String get achMagicResonanceTitle => 'Résonance Magique';

  @override
  String get achMagicResonanceDesc =>
      'Recharge complètement l\'énergie de la Boule sans lui poser une seule question.';

  @override
  String get achFateTesterTitle => 'Testeur du Destin';

  @override
  String get achFateTesterDesc =>
      'Interroge la Boule 3 fois dans la même journée.';

  @override
  String get achEclipseObserverTitle => 'Observateur de l\'Éclipse';

  @override
  String get achEclipseObserverRiddle =>
      'Parfois il faut monter pour voir l\'ombre couvrir un instant la lumière. Trouve ton sommet.';

  @override
  String get achEclipseObserverDesc =>
      'Tu as laissé un doute en brouillon plusieurs jours, puis tu es revenu prendre une décision claire.';

  @override
  String get achEclipseObserverQuote =>
      'Même le soleil revient quand l\'ombre passe.';

  @override
  String get achPerfectAlignmentTitle => 'Alignement Parfait';

  @override
  String get achPerfectAlignmentRiddle =>
      'Un événement rarissime, où six sphères s\'alignent en une seule ligne. Mets tes pensées dans le même ordre.';

  @override
  String get achPerfectAlignmentDesc =>
      '6 décisions d\'affilée dans la même catégorie, sans jamais interroger la Boule Magique.';

  @override
  String get achPerfectAlignmentQuote =>
      'La clarté est une ligne, pas une dispersion.';

  @override
  String get achOrhekiaHeightTitle => 'Hauteur d\'Orhekia';

  @override
  String get achOrhekiaHeightRiddle =>
      'Plus le point de vue est haut, plus l\'horizon est clair. Écarte tous les obstacles sur ton chemin.';

  @override
  String get achOrhekiaHeightDesc =>
      'Tu as rempli les quatre blocs du Carré sans jamais utiliser la touche retour arrière.';

  @override
  String get achOrhekiaHeightQuote => 'Un souffle, une pensée, une vérité.';

  @override
  String get achOracleWhisperTitle => 'Murmure de l\'Oracle';

  @override
  String get achOracleWhisperRiddle =>
      'La Boule connaît la réponse, mais parfois elle a besoin de temps pour réfléchir. Secoue-la, mais sans précipitation.';

  @override
  String get achOracleWhisperDesc =>
      'Tu as maintenu la Boule secouée 15+ secondes à l\'écran sans appuyer sur « Demander ».';

  @override
  String get achOracleWhisperQuote =>
      'La patience est une question posée sans mots.';

  @override
  String get locationRiverField => 'Rivière et champ';

  @override
  String get locationMountain => 'Montagne';

  @override
  String get locationStarPeak => 'Pic Étoilé';

  @override
  String get locationIsland => 'Île';

  @override
  String get locationOceanBoat => 'Océan en barque';

  @override
  String get locationOracleValley => 'Vallée de l\'Oracle';

  @override
  String get locationEclipseGate => 'Portail de l\'Éclipse';

  @override
  String get locationSixPlanetsPath => 'Sentier des Six Planètes';

  @override
  String get locationSolarSystem => 'Système Solaire';

  @override
  String get locationConstellations => 'Constellations';

  @override
  String get locationMilkyWay => 'Galaxie Voie Lactée';

  @override
  String get locationLargestGalaxy => 'La plus grande galaxie connue';

  @override
  String get locationUniverse => 'Image de l\'univers';

  @override
  String get locationHumanBrain => 'Cerveau humain';

  @override
  String get locationHomeOutside => 'Maison (Dehors)';

  @override
  String get locationHomeInsideFinal => 'Maison (Dedans)';

  @override
  String homeMapDecisionsCount(int count) {
    return 'Décisions prises : $count';
  }

  @override
  String homeMapStreak(int count) {
    return 'Série de jours : $count';
  }

  @override
  String get homeMapStartDecision => 'Prendre une décision';

  @override
  String get homeMapLocationLocked => 'Ce lieu est encore verrouillé';

  @override
  String get homeMapDecisionsHereTitle => 'Décisions ici';

  @override
  String get homeMapNoDecisionsHere => 'Aucune décision ici pour l\'instant';

  @override
  String get achievementsScreenTitle => 'Succès';

  @override
  String get achievementsCategoryBehavioral => 'Comportementaux';

  @override
  String get achievementsCategoryAnalytical => 'Analytiques';

  @override
  String get achievementsCategoryNarrativeAstro => 'Narratifs';

  @override
  String get achievementsCategoryMagicBall => 'Boule Magique';

  @override
  String get mindfulnessScreenTitle => 'Échelle de Pleine Conscience';

  @override
  String get mindfulnessLevelSeeker => 'Chercheur';

  @override
  String get mindfulnessLevelObserver => 'Observateur';

  @override
  String get mindfulnessLevelRationalist => 'Rationalisateur';

  @override
  String get mindfulnessLevelBalanceMaster => 'Maître de l\'Équilibre';

  @override
  String get mindfulnessLevelGuardianOfClarity => 'Gardien de la Clarté';

  @override
  String mindfulnessScoreLabel(int score) {
    return '$score points de conscience';
  }

  @override
  String mindfulnessProgressToNext(int percent) {
    return 'Vers le niveau suivant : $percent%';
  }

  @override
  String get mindfulnessMaxLevelReached =>
      'Tu as atteint le sommet de la pleine conscience';

  @override
  String mindfulnessLevelUpMessage(String level) {
    return 'Nouveau niveau : $level !';
  }

  @override
  String get decisionTagWork => 'Travail';

  @override
  String get decisionTagRelationships => 'Relations';

  @override
  String get decisionTagHealth => 'Santé';

  @override
  String get decisionTagFinances => 'Finances';

  @override
  String get decisionTagPersonalGrowth => 'Développement Personnel';

  @override
  String get decisionTagOther => 'Autre';

  @override
  String get decisionTagPickerLabel => 'Catégorie (facultatif)';

  @override
  String get statsScreenTitle => 'Mes Décisions';

  @override
  String get statsEmptyState =>
      'Pas encore de décision terminée — prends la première pour voir tes statistiques';

  @override
  String get settingsScreenTitle => 'Paramètres';

  @override
  String get settingsSubscriptionNone => 'Aucun abonnement actif';

  @override
  String settingsSubscriptionExpiresOn(String date) {
    return 'Actif jusqu\'au $date';
  }

  @override
  String get settingsUpgradeButton => 'Passer à Premium';

  @override
  String get settingsLanguageSystemDefault => 'Système par défaut';
}
