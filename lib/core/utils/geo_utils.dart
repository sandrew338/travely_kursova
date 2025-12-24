import 'dart:math';

/// Utility class for geographical calculations
class GeoUtils {
  GeoUtils._();

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// Check if distance is within acceptable range for walking tour
  /// Default max distance is 20km (anti-teleport threshold)
  static bool isWithinWalkingDistance(
    double userLat,
    double userLon,
    double destLat,
    double destLon, {
    double maxDistanceKm = 20.0,
  }) {
    final distance = calculateDistanceKm(userLat, userLon, destLat, destLon);
    return distance <= maxDistanceKm;
  }

  /// Anti-teleport check constant
  static const double maxBookingDistanceKm = 20.0;

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.round()} km';
    }
  }
}
