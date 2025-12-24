import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/geo_utils.dart';

/// Result from Directions API containing polyline and route info
class DirectionsResult {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final int durationSeconds;
  final String distanceText;
  final String durationText;

  const DirectionsResult({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.distanceText,
    required this.durationText,
  });

  double get distanceKm => distanceMeters / 1000;

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours год $minutes хв';
    }
    return '$minutes хв';
  }
}

/// Validation result for route generation
class RouteValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double? distanceKm;
  final List<LatLng>? invalidPoints;

  const RouteValidationResult({
    required this.isValid,
    this.errorMessage,
    this.distanceKm,
    this.invalidPoints,
  });

  factory RouteValidationResult.valid() => const RouteValidationResult(
        isValid: true,
      );

  factory RouteValidationResult.tooFar(double distanceKm) =>
      RouteValidationResult(
        isValid: false,
        errorMessage:
            'Пункт призначення занадто далеко (${GeoUtils.formatDistance(distanceKm)} > 20 км) для пішої екскурсії.',
        distanceKm: distanceKm,
      );

  factory RouteValidationResult.pointsOutsideRadius(
    List<LatLng> invalidPoints,
    double radiusKm,
  ) =>
      RouteValidationResult(
        isValid: false,
        errorMessage:
            '${invalidPoints.length} точок знаходяться за межами радіусу ${radiusKm.toStringAsFixed(1)} км.',
        invalidPoints: invalidPoints,
      );

  factory RouteValidationResult.noPoints() => const RouteValidationResult(
        isValid: false,
        errorMessage: 'Не знайдено жодних точок для маршруту.',
      );
}

/// Service for Google Directions API integration
class DirectionsService {
  final http.Client _client;

  /// Maximum distance for walking tour (20 km)
  static const double maxWalkingDistanceKm = 20.0;

  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  /// Validate route before generation
  /// Checks distance cap and radius enforcement
  RouteValidationResult validateRoute({
    required LatLng userLocation,
    required LatLng destination,
    required List<LatLng> landmarks,
    required double radiusKm,
  }) {
    // 1. Distance Cap: Check if destination is too far (> 20km)
    final distanceToDestination = GeoUtils.calculateDistanceKm(
      userLocation.latitude,
      userLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    if (distanceToDestination > maxWalkingDistanceKm) {
      return RouteValidationResult.tooFar(distanceToDestination);
    }

    // 2. Radius Enforcement: Check all landmarks are within radius
    if (landmarks.isEmpty) {
      return RouteValidationResult.noPoints();
    }

    final invalidPoints = <LatLng>[];
    for (final point in landmarks) {
      final distanceFromCenter = GeoUtils.calculateDistanceKm(
        destination.latitude,
        destination.longitude,
        point.latitude,
        point.longitude,
      );

      if (distanceFromCenter > radiusKm) {
        invalidPoints.add(point);
      }
    }

    if (invalidPoints.isNotEmpty) {
      return RouteValidationResult.pointsOutsideRadius(invalidPoints, radiusKm);
    }

    return RouteValidationResult.valid();
  }

  /// Filter landmarks to only include those within the specified radius
  List<LatLng> filterLandmarksWithinRadius({
    required LatLng center,
    required List<LatLng> landmarks,
    required double radiusKm,
  }) {
    return landmarks.where((point) {
      final distance = GeoUtils.calculateDistanceKm(
        center.latitude,
        center.longitude,
        point.latitude,
        point.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Fetch route polyline from Google Directions API
  /// Returns realistic road-following path
  Future<DirectionsResult?> fetchRoutePolyline({
    required List<LatLng> points,
    String mode = 'walking',
  }) async {
    if (points.length < 2) return null;

    if (AppConstants.googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      // No API key - return straight line fallback
      return _createStraightLineFallback(points);
    }

    try {
      final origin = points.first;
      final destination = points.last;

      // Build waypoints string (all points except first and last)
      String? waypointsParam;
      if (points.length > 2) {
        final waypoints = points.sublist(1, points.length - 1);
        final waypointStrings =
            waypoints.map((p) => '${p.latitude},${p.longitude}').join('|');
        waypointsParam = 'optimize:true|$waypointStrings';
      }

      final queryParams = <String, String>{
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': mode,
        'key': AppConstants.googleMapsApiKey,
      };

      if (waypointsParam != null) {
        queryParams['waypoints'] = waypointsParam;
      }

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        queryParams,
      );

      final response = await _client.get(uri);
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json['status'] != 'OK') {
        // API error - fall back to straight lines
        return _createStraightLineFallback(points);
      }

      final routes = json['routes'] as List;
      if (routes.isEmpty) {
        return _createStraightLineFallback(points);
      }

      final route = routes.first as Map<String, dynamic>;
      final overviewPolyline =
          route['overview_polyline']['points'] as String;

      // Decode the polyline
      final decodedPoints = _decodePolyline(overviewPolyline);

      // Calculate total distance and duration from legs
      final legs = route['legs'] as List;
      double totalDistanceMeters = 0;
      int totalDurationSeconds = 0;

      for (final leg in legs) {
        totalDistanceMeters +=
            (leg['distance']['value'] as num).toDouble();
        totalDurationSeconds += (leg['duration']['value'] as num).toInt();
      }

      return DirectionsResult(
        polylinePoints: decodedPoints,
        distanceMeters: totalDistanceMeters,
        durationSeconds: totalDurationSeconds,
        distanceText: _formatDistance(totalDistanceMeters),
        durationText: _formatDuration(totalDurationSeconds),
      );
    } catch (e) {
      // On error, return straight line fallback
      return _createStraightLineFallback(points);
    }
  }

  /// Decode Google's encoded polyline string to list of LatLng
  /// Based on Google's Polyline Algorithm
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      // Decode latitude
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // Decode longitude
      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  /// Create interpolated path between points (smooth fallback)
  DirectionsResult _createStraightLineFallback(List<LatLng> points) {
    if (points.length < 2) {
      return DirectionsResult(
        polylinePoints: points,
        distanceMeters: 0,
        durationSeconds: 0,
        distanceText: '0 м',
        durationText: '0 хв',
      );
    }

    // Create interpolated points for smoother appearance
    final interpolatedPoints = <LatLng>[];
    for (int i = 0; i < points.length - 1; i++) {
      interpolatedPoints.addAll(
        _interpolatePoints(points[i], points[i + 1], 10),
      );
    }
    interpolatedPoints.add(points.last);

    // Calculate total distance
    double totalDistanceMeters = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistanceMeters += GeoUtils.calculateDistanceKm(
            points[i].latitude,
            points[i].longitude,
            points[i + 1].latitude,
            points[i + 1].longitude,
          ) *
          1000;
    }

    // Estimate duration (5 km/h walking speed)
    final durationSeconds = (totalDistanceMeters / 1000 / 5 * 3600).round();

    return DirectionsResult(
      polylinePoints: interpolatedPoints,
      distanceMeters: totalDistanceMeters,
      durationSeconds: durationSeconds,
      distanceText: _formatDistance(totalDistanceMeters),
      durationText: _formatDuration(durationSeconds),
    );
  }

  /// Interpolate points between two coordinates for smoother lines
  List<LatLng> _interpolatePoints(LatLng start, LatLng end, int segments) {
    final points = <LatLng>[];
    for (int i = 0; i < segments; i++) {
      final t = i / segments;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;
      points.add(LatLng(lat, lng));
    }
    return points;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} м';
    }
    return '${(meters / 1000).toStringAsFixed(1)} км';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours год $minutes хв';
    }
    return '$minutes хв';
  }
}

