/// Тип маркера прогресса на карте локации.
enum LocationMarkerType { flag, star, planet }

/// Статический конфиг локации (не хранится в Firestore).
/// Полный список — 16 локаций, см. FLUTTER_ARCHITECTURE_PLAN.md §2.3.
class LocationModel {
  const LocationModel({
    required this.index,
    required this.key,
    required this.requiredDecisions,
    required this.nameKey,
    required this.backgroundAsset,
    this.rareEventAssets = const {},
    this.markerType = LocationMarkerType.flag,
  });

  /// 0-based индекс локации (0..15).
  final int index;

  /// Технический ключ, напр. river_field, mountain, eclipse_gate.
  final String key;

  /// Сколько решений нужно принять НА этой локации, чтобы открыть следующую.
  /// Формула из ТЗ: requiredDecisions(level) = 5 + 2 × (level - 1).
  final int requiredDecisions;

  /// Ключ локализации названия локации.
  final String nameKey;

  final String backgroundAsset;

  /// Lottie-анимации редких небесных явлений (парад планет, затмение),
  /// показываются поверх фона при streak >= 3. Ключ — имя события.
  final Map<String, String> rareEventAssets;

  final LocationMarkerType markerType;

  /// Кумулятивный порог (сумма requiredDecisions всех локаций до текущей включительно).
  static int cumulativeThreshold(int index) {
    return locations
        .take(index + 1)
        .fold(0, (sum, loc) => sum + loc.requiredDecisions);
  }

  /// true, если локация с индексом [index] уже открыта при [decisionsCount]
  /// завершённых решениях. Локация 0 (старт) открыта всегда. Локация i>0
  /// открывается, когда накоплен кумулятивный порог ПРЕДЫДУЩЕЙ локации
  /// (`cumulativeThreshold(index - 1)`) — см. FLUTTER_ARCHITECTURE_PLAN.md §2.3.
  static bool isUnlocked(int index, int decisionsCount) {
    if (index == 0) return true;
    return decisionsCount >= cumulativeThreshold(index - 1);
  }

  /// Индекс ТЕКУЩЕЙ (самой дальней открытой) локации при [decisionsCount]
  /// завершённых решениях — используется для `UserModel.currentLocationIndex`
  /// (см. RecordDecisionCompleted usecase, Этап 4).
  static int currentLocationIndexFor(int decisionsCount) {
    int current = 0;
    for (int i = 1; i < locations.length; i++) {
      if (isUnlocked(i, decisionsCount)) {
        current = i;
      } else {
        break;
      }
    }
    return current;
  }

  /// Полный маршрут — 16 локаций, requiredDecisions = 5 + 2×level.
  static const List<LocationModel> locations = [
    LocationModel(
      index: 0,
      key: 'river_field',
      requiredDecisions: 5,
      nameKey: 'locationRiverField',
      backgroundAsset: 'assets/images/locations/01_river_field.webp',
      markerType: LocationMarkerType.flag,
    ),
    LocationModel(
      index: 1,
      key: 'mountain',
      requiredDecisions: 7,
      nameKey: 'locationMountain',
      backgroundAsset: 'assets/images/locations/02_mountain.webp',
      markerType: LocationMarkerType.flag,
    ),
    LocationModel(
      index: 2,
      key: 'star_peak',
      requiredDecisions: 9,
      nameKey: 'locationStarPeak',
      backgroundAsset: 'assets/images/locations/03_star_peak.webp',
      markerType: LocationMarkerType.star,
    ),
    LocationModel(
      index: 3,
      key: 'island',
      requiredDecisions: 11,
      nameKey: 'locationIsland',
      backgroundAsset: 'assets/images/locations/04_island.webp',
      markerType: LocationMarkerType.flag,
    ),
    LocationModel(
      index: 4,
      key: 'ocean_boat',
      requiredDecisions: 13,
      nameKey: 'locationOceanBoat',
      backgroundAsset: 'assets/images/locations/05_ocean_boat.webp',
      markerType: LocationMarkerType.flag,
    ),
    LocationModel(
      index: 5,
      key: 'oracle_valley',
      requiredDecisions: 15,
      nameKey: 'locationOracleValley',
      backgroundAsset: 'assets/images/locations/06_oracle_valley.webp',
      markerType: LocationMarkerType.star,
    ),
    LocationModel(
      index: 6,
      key: 'eclipse_gate',
      requiredDecisions: 17,
      nameKey: 'locationEclipseGate',
      backgroundAsset: 'assets/images/locations/07_eclipse_gate.webp',
      rareEventAssets: {'eclipse': 'assets/lottie/eclipse.json'},
      markerType: LocationMarkerType.star,
    ),
    LocationModel(
      index: 7,
      key: 'six_planets_path',
      requiredDecisions: 19,
      nameKey: 'locationSixPlanetsPath',
      backgroundAsset: 'assets/images/locations/08_six_planets_path.webp',
      rareEventAssets: {'planet_parade': 'assets/lottie/planet_parade.json'},
      markerType: LocationMarkerType.planet,
    ),
    LocationModel(
      index: 8,
      key: 'solar_system',
      requiredDecisions: 21,
      nameKey: 'locationSolarSystem',
      backgroundAsset: 'assets/images/locations/09_solar_system.webp',
      markerType: LocationMarkerType.planet,
    ),
    LocationModel(
      index: 9,
      key: 'constellations',
      requiredDecisions: 23,
      nameKey: 'locationConstellations',
      backgroundAsset: 'assets/images/locations/10_constellations.webp',
      markerType: LocationMarkerType.star,
    ),
    LocationModel(
      index: 10,
      key: 'milky_way',
      requiredDecisions: 25,
      nameKey: 'locationMilkyWay',
      backgroundAsset: 'assets/images/locations/11_milky_way.webp',
      markerType: LocationMarkerType.star,
    ),
    LocationModel(
      index: 11,
      key: 'largest_galaxy',
      requiredDecisions: 27,
      nameKey: 'locationLargestGalaxy',
      backgroundAsset: 'assets/images/locations/12_largest_galaxy.webp',
      markerType: LocationMarkerType.star,
    ),
    LocationModel(
      index: 12,
      key: 'universe',
      requiredDecisions: 29,
      nameKey: 'locationUniverse',
      backgroundAsset: 'assets/images/locations/13_universe.webp',
      markerType: LocationMarkerType.star,
    ),
    LocationModel(
      index: 13,
      key: 'human_brain',
      requiredDecisions: 31,
      nameKey: 'locationHumanBrain',
      backgroundAsset: 'assets/images/locations/14_human_brain.webp',
      markerType: LocationMarkerType.flag,
    ),
    LocationModel(
      index: 14,
      key: 'home_outside',
      requiredDecisions: 33,
      nameKey: 'locationHomeOutside',
      backgroundAsset: 'assets/images/locations/15_home_outside.webp',
      markerType: LocationMarkerType.flag,
    ),
    LocationModel(
      index: 15,
      key: 'home_inside_final',
      requiredDecisions: 35,
      nameKey: 'locationHomeInsideFinal',
      backgroundAsset: 'assets/images/locations/16_home_inside_final.webp',
      markerType: LocationMarkerType.flag,
    ),
  ];
}
