/// Audio priority levels for audio guides
enum AudioPriority {
  low,
  medium,
  high,
}

/// Difficulty levels for routes
enum RouteDifficulty {
  easy,
  medium,
  hard,
  extreme,
}

/// Transport types for routes
enum TransportType {
  walking,
  bicycle,
  car,
  bus,
}

/// Review target types
enum ReviewType {
  excursion,
  route,
  landmark,
}

/// Extension methods for AudioPriority
extension AudioPriorityExtension on AudioPriority {
  String get displayName {
    switch (this) {
      case AudioPriority.low:
        return 'Низький';
      case AudioPriority.medium:
        return 'Середній';
      case AudioPriority.high:
        return 'Високий';
    }
  }

  int get sortOrder {
    switch (this) {
      case AudioPriority.low:
        return 0;
      case AudioPriority.medium:
        return 1;
      case AudioPriority.high:
        return 2;
    }
  }
}

/// Extension methods for RouteDifficulty
extension RouteDifficultyExtension on RouteDifficulty {
  String get displayName {
    switch (this) {
      case RouteDifficulty.easy:
        return 'Легкий';
      case RouteDifficulty.medium:
        return 'Середній';
      case RouteDifficulty.hard:
        return 'Важкий';
      case RouteDifficulty.extreme:
        return 'Екстремальний';
    }
  }

  String get icon {
    switch (this) {
      case RouteDifficulty.easy:
        return '🟢';
      case RouteDifficulty.medium:
        return '🟡';
      case RouteDifficulty.hard:
        return '🟠';
      case RouteDifficulty.extreme:
        return '🔴';
    }
  }
}

/// Extension methods for TransportType
extension TransportTypeExtension on TransportType {
  String get displayName {
    switch (this) {
      case TransportType.walking:
        return 'Пішки';
      case TransportType.bicycle:
        return 'Велосипед';
      case TransportType.car:
        return 'Автомобіль';
      case TransportType.bus:
        return 'Автобус';
    }
  }

  String get icon {
    switch (this) {
      case TransportType.walking:
        return '🚶';
      case TransportType.bicycle:
        return '🚴';
      case TransportType.car:
        return '🚗';
      case TransportType.bus:
        return '🚌';
    }
  }

  /// Average speed in km/h for estimation
  double get averageSpeedKmh {
    switch (this) {
      case TransportType.walking:
        return 5.0;
      case TransportType.bicycle:
        return 15.0;
      case TransportType.car:
        return 50.0;
      case TransportType.bus:
        return 30.0;
    }
  }
}

/// Extension methods for ReviewType
extension ReviewTypeExtension on ReviewType {
  String get displayName {
    switch (this) {
      case ReviewType.excursion:
        return 'Екскурсія';
      case ReviewType.route:
        return 'Маршрут';
      case ReviewType.landmark:
        return 'Пам\'ятка';
    }
  }
}
