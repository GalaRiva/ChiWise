import '../../../data/models/location_model.dart';

/// Прогресс одной локации по отношению к текущему `decisionsCount`
/// пользователя — вычисляется [GetLocationsProgress], используется картой
/// локаций (см. presentation/screens/home_map/home_map_screen.dart).
class LocationProgress {
  const LocationProgress({
    required this.location,
    required this.isUnlocked,
    required this.isCurrent,
  });

  final LocationModel location;
  final bool isUnlocked;

  /// true, если это САМАЯ ДАЛЬНЯЯ открытая локация (currentLocationIndexFor) —
  /// используется для выделения активного маркера золотым цветом на карте.
  final bool isCurrent;
}

/// Usecase: строит прогресс по всем 16 локациям для заданного
/// `decisionsCount`, используя статические хелперы `LocationModel`
/// (isUnlocked/currentLocationIndexFor, см. FLUTTER_ARCHITECTURE_PLAN.md §2.3).
/// Чистая функция без сайд-эффектов и обращений к репозиториям — держим
/// Notifier/UI тонкими, вся логика геймификации локализована здесь.
class GetLocationsProgress {
  const GetLocationsProgress();

  List<LocationProgress> call(int decisionsCount) {
    final int currentIndex =
        LocationModel.currentLocationIndexFor(decisionsCount);

    return LocationModel.locations.map((location) {
      final bool isUnlocked =
          LocationModel.isUnlocked(location.index, decisionsCount);
      return LocationProgress(
        location: location,
        isUnlocked: isUnlocked,
        isCurrent: location.index == currentIndex,
      );
    }).toList();
  }
}
