// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Chi Wise Magic';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingTitle1 =>
      'A menudo nos enfrentamos a decisiones difíciles';

  @override
  String get onboardingTitle2 =>
      '¡A veces el miedo nos detiene! ¡Las emociones nublan la mente!';

  @override
  String get onboardingTitle3 =>
      'A veces hay que tomar una decisión importante rápido, pero es difícil hacerlo';

  @override
  String get onboardingTitle4 =>
      'Toma decisiones conscientes de las que nunca sentirás culpa ni arrepentimiento';

  @override
  String get authContinueWithApple => 'Continuar con Apple';

  @override
  String get authContinueWithGoogle => 'Continuar con Google';

  @override
  String get authContinueAnonymously => 'Continuar sin registrarse';

  @override
  String get decisionDoubtPrompt => 'Si no sabes qué hacer... escribe tu duda';

  @override
  String get decisionQuestion1 => '¿Qué pasará si sucede?';

  @override
  String get decisionQuestion2 => '¿Qué pasará si no sucede?';

  @override
  String get decisionQuestion3 => '¿Qué NO pasará si sucede?';

  @override
  String get decisionQuestion4 => '¿Qué NO pasará si no sucede?';

  @override
  String get decisionNext => 'Siguiente';

  @override
  String get decisionBack => 'Atrás';

  @override
  String get decisionCancel => 'Cancelar';

  @override
  String get decisionAccept => 'Decisión tomada';

  @override
  String get decisionCancelConfirmTitle => '¿Cancelar esta entrada?';

  @override
  String get decisionCancelConfirmMessage =>
      'El borrador se eliminará y no podrá recuperarse.';

  @override
  String get decisionCancelConfirmYes => 'Sí, cancelar';

  @override
  String get decisionCancelConfirmNo => 'Continuar';

  @override
  String get decisionSummaryTitle => 'Tu decisión';

  @override
  String get decisionSummarySubtitle =>
      'Revisa tus respuestas y decide con claridad';

  @override
  String get decisionDetailSave => 'Guardar';

  @override
  String get decisionDetailSaved => 'Cambios guardados';

  @override
  String get decisionDetailNotFound => 'Registro no encontrado';

  @override
  String get magicBallAsk => 'Preguntar a la bola';

  @override
  String get magicBallReturn => 'Volver';

  @override
  String get magicBallWarning =>
      'Muestra respeto a la Bola Mágica y formula tus preguntas con claridad. Concéntrate en tu pregunta. Sé sincero.';

  @override
  String get magicBallShakeHint => 'Toca la bola o agita el teléfono';

  @override
  String get magicBallLimitReachedMessage =>
      'Se agotaron tus preguntas gratuitas a la Bola. Obtén acceso ilimitado para seguir preguntando.';

  @override
  String get magicBallGoToPaywall => 'Obtener acceso ilimitado';

  @override
  String get magicBallLowEnergyMessage =>
      'La Bola está cansada y no puede responder. Toma una decisión consciente en el mapa para recargar su energía.';

  @override
  String get magicBallGoToDecision => 'Tomar una decisión';

  @override
  String get paywallTitle => '¡Consigue la Bola Mágica!';

  @override
  String get paywallSubtitle =>
      'Haz preguntas ilimitadas y obtén respuestas al instante.';

  @override
  String get paywallMonthly => 'Mensual';

  @override
  String get paywallYearly => 'Anual';

  @override
  String get paywallLifetime => 'De por vida';

  @override
  String paywallYearlySavings(String amount) {
    return '¡Ahorra $amount!';
  }

  @override
  String get paywallContinue => 'Continuar';

  @override
  String get paywallRestoreButton => 'Restaurar compras';

  @override
  String get paywallRestoreFailed =>
      'No se encontraron compras activas para restaurar.';

  @override
  String get paywallPurchaseUnavailable =>
      'Las compras aún no están disponibles: la tienda no está configurada.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSubscription => 'Suscripción';

  @override
  String get ratingTitle => '¿Qué tal tu experiencia?';

  @override
  String get ratingLowStarsThanks =>
      'Gracias por tu opinión — cuéntanos más para mejorar';

  @override
  String get ratingHighStarsThanks => '¡Gracias! ¿Nos valoras en la tienda?';

  @override
  String get ratingSubmit => 'Enviar';

  @override
  String get ratingSkip => 'Ahora no';

  @override
  String get ratingDone => 'Listo';

  @override
  String get ratingEmailSubject => 'Comentarios sobre Chi Wise Magic';

  @override
  String get ratingEmailBody => 'Cuéntanos qué podríamos mejorar:';

  @override
  String get achOrbitalStabilityTitle => 'Estabilidad Orbital';

  @override
  String get achOrbitalStabilityDesc =>
      'Toma al menos una decisión cada día durante 7 días seguidos.';

  @override
  String get achNightOwlSageTitle => 'Sabio Nocturno';

  @override
  String get achNightOwlSageDesc =>
      'Completa el Cuadro y toma una decisión después de las 23:00.';

  @override
  String get achBalanceMasterTitle => 'Maestro del Equilibrio';

  @override
  String get achBalanceMasterDesc =>
      'Escribe la misma cantidad de argumentos en los cuatro bloques.';

  @override
  String get achDeepAnalysisTitle => 'Análisis Profundo';

  @override
  String get achDeepAnalysisDesc =>
      'Escribe más de 5 puntos detallados en cada bloque de una misma duda.';

  @override
  String get achIllusionBreakerTitle => 'Rompedor de Ilusiones';

  @override
  String get achIllusionBreakerDesc =>
      'El bloque más difícil —«qué no pasará si no ocurre»— resulta ser el más detallado.';

  @override
  String get achEclipseCatcherTitle => 'Cazador de Eclipses';

  @override
  String get achEclipseCatcherDesc =>
      'Resuelve una duda que estuvo como borrador más tiempo que ninguna otra (7+ días).';

  @override
  String get achPlanetParadeTitle => 'Desfile de Planetas';

  @override
  String get achPlanetParadeDesc =>
      'Toma 6 decisiones seguidas dentro de la misma categoría.';

  @override
  String get achLightMindTitle => 'Mente Clara';

  @override
  String get achLightMindDesc =>
      'Pasa de una ubicación terrenal (Montaña/Isla) a una cósmica (Pico Estelar).';

  @override
  String get achMagicResonanceTitle => 'Resonancia Mágica';

  @override
  String get achMagicResonanceDesc =>
      'Recarga por completo la energía de la Bola sin hacerle ni una sola pregunta.';

  @override
  String get achFateTesterTitle => 'Desafiante del Destino';

  @override
  String get achFateTesterDesc => 'Pregunta a la Bola 3 veces en un mismo día.';

  @override
  String get achEclipseObserverTitle => 'Observador del Eclipse';

  @override
  String get achEclipseObserverRiddle =>
      'A veces hay que subir para ver cómo la sombra cubre brevemente la luz. Encuentra tu cima.';

  @override
  String get achEclipseObserverDesc =>
      'Dejaste una duda como borrador varios días y luego volviste y tomaste una decisión clara.';

  @override
  String get achEclipseObserverQuote =>
      'Hasta el sol regresa cuando la sombra pasa.';

  @override
  String get achPerfectAlignmentTitle => 'Alineación Perfecta';

  @override
  String get achPerfectAlignmentRiddle =>
      'Un suceso rarísimo: seis esferas alineadas en una sola línea. Pon tus pensamientos en el mismo orden.';

  @override
  String get achPerfectAlignmentDesc =>
      '6 decisiones seguidas en la misma categoría, sin preguntar ni una vez a la Bola Mágica.';

  @override
  String get achPerfectAlignmentQuote =>
      'La claridad es una línea, no una dispersión.';

  @override
  String get achOrhekiaHeightTitle => 'Altura de Orhekia';

  @override
  String get achOrhekiaHeightRiddle =>
      'Cuanto más alto el mirador, más claro el horizonte. Despeja cualquier obstáculo en tu camino.';

  @override
  String get achOrhekiaHeightDesc =>
      'Completaste los cuatro bloques del Cuadro sin usar ni una vez la tecla de retroceso.';

  @override
  String get achOrhekiaHeightQuote => 'Un aliento, un pensamiento, una verdad.';

  @override
  String get achOracleWhisperTitle => 'Susurro del Oráculo';

  @override
  String get achOracleWhisperRiddle =>
      'La Bola conoce la respuesta, pero a veces necesita tiempo para pensar. Agítala, pero sin prisa.';

  @override
  String get achOracleWhisperDesc =>
      'Mantuviste la Bola agitándose 15+ segundos en la pantalla sin pulsar «Preguntar».';

  @override
  String get achOracleWhisperQuote =>
      'La paciencia es una pregunta hecha sin palabras.';

  @override
  String get locationRiverField => 'Río y campo';

  @override
  String get locationMountain => 'Montaña';

  @override
  String get locationStarPeak => 'Pico Estelar';

  @override
  String get locationIsland => 'Isla';

  @override
  String get locationOceanBoat => 'Océano en barca';

  @override
  String get locationOracleValley => 'Valle del Oráculo';

  @override
  String get locationEclipseGate => 'Puerta del Eclipse';

  @override
  String get locationSixPlanetsPath => 'Sendero de los Seis Planetas';

  @override
  String get locationSolarSystem => 'Sistema Solar';

  @override
  String get locationConstellations => 'Constelaciones';

  @override
  String get locationMilkyWay => 'Galaxia Vía Láctea';

  @override
  String get locationLargestGalaxy => 'La galaxia conocida más grande';

  @override
  String get locationUniverse => 'Imagen del universo';

  @override
  String get locationHumanBrain => 'Cerebro humano';

  @override
  String get locationHomeOutside => 'Casa (Afuera)';

  @override
  String get locationHomeInsideFinal => 'Casa (Adentro)';

  @override
  String homeMapDecisionsCount(int count) {
    return 'Decisiones tomadas: $count';
  }

  @override
  String homeMapStreak(int count) {
    return 'Racha de días: $count';
  }

  @override
  String get homeMapStartDecision => 'Tomar una decisión';

  @override
  String get homeMapLocationLocked => 'Esta ubicación todavía está bloqueada';

  @override
  String get homeMapDecisionsHereTitle => 'Decisiones aquí';

  @override
  String get homeMapNoDecisionsHere =>
      'Aún no hay decisiones en esta ubicación';

  @override
  String get achievementsScreenTitle => 'Logros';

  @override
  String get achievementsCategoryBehavioral => 'De comportamiento';

  @override
  String get achievementsCategoryAnalytical => 'Analíticos';

  @override
  String get achievementsCategoryNarrativeAstro => 'Narrativos';

  @override
  String get achievementsCategoryMagicBall => 'Bola Mágica';

  @override
  String get mindfulnessScreenTitle => 'Escala de Conciencia';

  @override
  String get mindfulnessLevelSeeker => 'Buscador';

  @override
  String get mindfulnessLevelObserver => 'Observador';

  @override
  String get mindfulnessLevelRationalist => 'Racionalizador';

  @override
  String get mindfulnessLevelBalanceMaster => 'Maestro del Equilibrio';

  @override
  String get mindfulnessLevelGuardianOfClarity => 'Guardián de la Claridad';

  @override
  String mindfulnessScoreLabel(int score) {
    return '$score puntos de conciencia';
  }

  @override
  String mindfulnessProgressToNext(int percent) {
    return 'Para el siguiente nivel: $percent%';
  }

  @override
  String get mindfulnessMaxLevelReached =>
      'Has alcanzado la cima de la conciencia';

  @override
  String mindfulnessLevelUpMessage(String level) {
    return '¡Nuevo nivel: $level!';
  }

  @override
  String get decisionTagWork => 'Trabajo';

  @override
  String get decisionTagRelationships => 'Relaciones';

  @override
  String get decisionTagHealth => 'Salud';

  @override
  String get decisionTagFinances => 'Finanzas';

  @override
  String get decisionTagPersonalGrowth => 'Crecimiento Personal';

  @override
  String get decisionTagOther => 'Otro';

  @override
  String get decisionTagPickerLabel => 'Categoría (opcional)';

  @override
  String get statsScreenTitle => 'Mis Decisiones';

  @override
  String get statsEmptyState =>
      'Aún no hay decisiones completadas — toma la primera para ver tus estadísticas';

  @override
  String get settingsScreenTitle => 'Ajustes';

  @override
  String get settingsSubscriptionNone => 'Sin suscripción activa';

  @override
  String settingsSubscriptionExpiresOn(String date) {
    return 'Activa hasta $date';
  }

  @override
  String get settingsUpgradeButton => 'Obtener Premium';

  @override
  String get settingsLanguageSystemDefault => 'Predeterminado del sistema';
}
