import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../excursion/domain/entities/excursion_entity.dart';

/// Filter result from the map filter sheet
class FilterResult {
  final String locationQuery;
  final String? destinationQuery;
  final double radiusKm;
  final List<String> selectedTypes;

  const FilterResult({
    required this.locationQuery,
    this.destinationQuery,
    required this.radiusKm,
    required this.selectedTypes,
  });
}

/// Popular location with coordinates for autocomplete
class PopularLocation {
  final String name;
  final String country;
  final LatLng coordinates;
  final String imageUrl;

  const PopularLocation({
    required this.name,
    required this.country,
    required this.coordinates,
    required this.imageUrl,
  });

  String get displayName => '$name, $country';
}

/// Service for interacting with Google Places API
class PlacesService {
  final http.Client _client;
  final Random _random = Random();

  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  /// Predefined popular locations (works without API)
  static const List<PopularLocation> popularLocations = [
    // Ukraine
    PopularLocation(
      name: 'Kyiv',
      country: 'Ukraine',
      coordinates: LatLng(50.4501, 30.5234),
      imageUrl:
          'https://images.unsplash.com/photo-1561542320-9a18cd340469?w=800',
    ),
    PopularLocation(
      name: 'Lviv',
      country: 'Ukraine',
      coordinates: LatLng(49.8397, 24.0297),
      imageUrl:
          'https://images.unsplash.com/photo-1565008576549-57569a49371d?w=800',
    ),
    PopularLocation(
      name: 'Odesa',
      country: 'Ukraine',
      coordinates: LatLng(46.4825, 30.7233),
      imageUrl:
          'https://images.unsplash.com/photo-1555990538-1e7d5e12f5e9?w=800',
    ),
    PopularLocation(
      name: 'Kamianets-Podilskyi',
      country: 'Ukraine',
      coordinates: LatLng(48.6833, 26.5667),
      imageUrl:
          'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
    ),
    PopularLocation(
      name: 'Kharkiv',
      country: 'Ukraine',
      coordinates: LatLng(49.9935, 36.2304),
      imageUrl:
          'https://images.unsplash.com/photo-1596484552834-6a58f850e0a1?w=800',
    ),
    // Europe
    PopularLocation(
      name: 'Paris',
      country: 'France',
      coordinates: LatLng(48.8566, 2.3522),
      imageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
    ),
    PopularLocation(
      name: 'Rome',
      country: 'Italy',
      coordinates: LatLng(41.9028, 12.4964),
      imageUrl:
          'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
    ),
    PopularLocation(
      name: 'Barcelona',
      country: 'Spain',
      coordinates: LatLng(41.3851, 2.1734),
      imageUrl:
          'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800',
    ),
    PopularLocation(
      name: 'Amsterdam',
      country: 'Netherlands',
      coordinates: LatLng(52.3676, 4.9041),
      imageUrl:
          'https://images.unsplash.com/photo-1534351590666-13e3e96b5017?w=800',
    ),
    PopularLocation(
      name: 'Prague',
      country: 'Czech Republic',
      coordinates: LatLng(50.0755, 14.4378),
      imageUrl:
          'https://images.unsplash.com/photo-1541849546-216549ae216d?w=800',
    ),
    PopularLocation(
      name: 'Vienna',
      country: 'Austria',
      coordinates: LatLng(48.2082, 16.3738),
      imageUrl:
          'https://images.unsplash.com/photo-1516550893923-42d28e5677af?w=800',
    ),
    PopularLocation(
      name: 'Berlin',
      country: 'Germany',
      coordinates: LatLng(52.5200, 13.4050),
      imageUrl:
          'https://images.unsplash.com/photo-1560969184-10fe8719e047?w=800',
    ),
    PopularLocation(
      name: 'London',
      country: 'UK',
      coordinates: LatLng(51.5074, -0.1278),
      imageUrl:
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800',
    ),
    PopularLocation(
      name: 'Warsaw',
      country: 'Poland',
      coordinates: LatLng(52.2297, 21.0122),
      imageUrl:
          'https://images.unsplash.com/photo-1519197924294-4ba991a11128?w=800',
    ),
    PopularLocation(
      name: 'Krakow',
      country: 'Poland',
      coordinates: LatLng(50.0647, 19.9450),
      imageUrl:
          'https://images.unsplash.com/photo-1574069280619-4bdfeb9c6d8e?w=800',
    ),
    // Asia
    PopularLocation(
      name: 'Tokyo',
      country: 'Japan',
      coordinates: LatLng(35.6762, 139.6503),
      imageUrl:
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
    ),
    PopularLocation(
      name: 'Bangkok',
      country: 'Thailand',
      coordinates: LatLng(13.7563, 100.5018),
      imageUrl:
          'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=800',
    ),
    PopularLocation(
      name: 'Bali',
      country: 'Indonesia',
      coordinates: LatLng(-8.3405, 115.0920),
      imageUrl:
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    ),
    // Americas
    PopularLocation(
      name: 'New York',
      country: 'USA',
      coordinates: LatLng(40.7128, -74.0060),
      imageUrl:
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800',
    ),
    PopularLocation(
      name: 'Los Angeles',
      country: 'USA',
      coordinates: LatLng(34.0522, -118.2437),
      imageUrl:
          'https://images.unsplash.com/photo-1534190760961-74e8c1c5c3da?w=800',
    ),
  ];

  /// Get autocomplete suggestions based on query
  List<PopularLocation> getAutocompleteSuggestions(String query) {
    if (query.isEmpty) {
      return popularLocations.take(8).toList();
    }

    final queryLower = query.toLowerCase();
    return popularLocations
        .where((loc) =>
            loc.name.toLowerCase().contains(queryLower) ||
            loc.country.toLowerCase().contains(queryLower) ||
            loc.displayName.toLowerCase().contains(queryLower))
        .take(8)
        .toList();
  }

  /// Geocode a location query to get lat/lng
  /// First checks predefined locations, then falls back to Google API
  Future<LatLng?> geocode(String query) async {
    if (query.isEmpty) return null;

    // First, try to find in predefined locations
    final predefined = _findPredefinedLocation(query);
    if (predefined != null) {
      return predefined.coordinates;
    }

    // Try Google Geocoding API if key is configured
    if (AppConstants.googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY') {
      try {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/geocode/json',
          {'address': query, 'key': AppConstants.googleMapsApiKey},
        );
        final res = await _client.get(uri);
        final json = jsonDecode(res.body) as Map<String, dynamic>;

        if (json['status'] == 'OK' && (json['results'] as List).isNotEmpty) {
          final loc = json['results'][0]['geometry']['location'];
          return LatLng(loc['lat'] as double, loc['lng'] as double);
        }
      } catch (e) {
        // Fall through to fuzzy match
      }
    }

    // Fuzzy match - try to find closest match in predefined locations
    final fuzzy = _fuzzyMatchLocation(query);
    if (fuzzy != null) {
      return fuzzy.coordinates;
    }

    return null;
  }

  /// Find a predefined location by exact or partial match
  PopularLocation? _findPredefinedLocation(String query) {
    final queryLower = query.toLowerCase().trim();

    // Exact match
    for (final loc in popularLocations) {
      if (loc.name.toLowerCase() == queryLower ||
          loc.displayName.toLowerCase() == queryLower) {
        return loc;
      }
    }

    // Partial match (starts with)
    for (final loc in popularLocations) {
      if (loc.name.toLowerCase().startsWith(queryLower) ||
          loc.displayName.toLowerCase().startsWith(queryLower)) {
        return loc;
      }
    }

    return null;
  }

  /// Fuzzy match location by similarity
  PopularLocation? _fuzzyMatchLocation(String query) {
    final queryLower = query.toLowerCase().trim();

    // Contains match
    for (final loc in popularLocations) {
      if (loc.name.toLowerCase().contains(queryLower) ||
          queryLower.contains(loc.name.toLowerCase())) {
        return loc;
      }
    }

    return null;
  }

  /// Get image URL for a location
  String? getLocationImageUrl(String query) {
    final loc = _findPredefinedLocation(query) ?? _fuzzyMatchLocation(query);
    return loc?.imageUrl;
  }

  /// Search for nearby places of a specific type (uses API if available)
  Future<List<Map<String, dynamic>>> searchNearby(
    LatLng center,
    double radiusMeters,
    String type,
  ) async {
    if (AppConstants.googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      return []; // No API key configured
    }

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        {
          'location': '${center.latitude},${center.longitude}',
          'radius': radiusMeters.toStringAsFixed(0),
          'type': type,
          'key': AppConstants.googleMapsApiKey,
        },
      );
      final res = await _client.get(uri);
      final json = jsonDecode(res.body) as Map<String, dynamic>;

      if (json['status'] != 'OK') {
        return [];
      }

      return (json['results'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Generate an excursion based on filter parameters
  /// Works with or without Google API - falls back to mock data
  Future<ExcursionEntity?> generateExcursion({
    required String locationQuery,
    String? destinationQuery,
    required double radiusKm,
    required List<String> selectedTypes,
    String? userId,
  }) async {
    // Geocode the location
    final start = await geocode(locationQuery);
    if (start == null) {
      // Even if geocoding fails, generate with default coordinates
      return _generateMockExcursion(
        locationQuery: locationQuery,
        destinationQuery: destinationQuery,
        radiusKm: radiusKm,
        selectedTypes: selectedTypes,
        center: const LatLng(48.8566, 2.3522), // Default to Paris
        userId: userId,
      );
    }

    // Use destination if provided, otherwise use start location
    final center = destinationQuery != null && destinationQuery.isNotEmpty
        ? (await geocode(destinationQuery)) ?? start
        : start;

    final allPlaces = <Map<String, dynamic>>[];

    // Try to search for each selected type via API
    for (final type in selectedTypes) {
      final apiType = _mapTypeToPlacesType(type);
      final results = await searchNearby(center, radiusKm * 1000, apiType);
      allPlaces.addAll(results);
    }

    if (allPlaces.isEmpty) {
      // If no places found with API, generate mock data
      return _generateMockExcursion(
        locationQuery: locationQuery,
        destinationQuery: destinationQuery,
        radiusKm: radiusKm,
        selectedTypes: selectedTypes,
        center: center,
        userId: userId,
      );
    }

    // Filter places with good ratings
    final filtered = allPlaces.where((p) {
      final rating = (p['rating'] ?? 0).toDouble();
      final reviews = (p['user_ratings_total'] ?? 0) as int;
      return rating >= 3.5 && reviews >= 10;
    }).toList();

    // If filtering removed everything, use all places
    final placesToUse = filtered.isNotEmpty ? filtered : allPlaces;

    // Shuffle and take up to 5 stops
    placesToUse.shuffle(_random);
    final stops = placesToUse.take(5).toList();

    if (stops.isEmpty) {
      return _generateMockExcursion(
        locationQuery: locationQuery,
        destinationQuery: destinationQuery,
        radiusKm: radiusKm,
        selectedTypes: selectedTypes,
        center: center,
        userId: userId,
      );
    }

    // Calculate average rating
    final avgRating = stops
            .map((p) => (p['rating'] ?? 4.0).toDouble())
            .fold<double>(0, (a, b) => a + b) /
        stops.length;

    final first = stops.first;
    final now = DateTime.now();

    // Build image URL
    String imageUrl;
    if (first['photos'] != null && (first['photos'] as List).isNotEmpty) {
      final photoRef = first['photos'][0]['photo_reference'];
      imageUrl = 'https://maps.googleapis.com/maps/api/place/photo'
          '?maxwidth=800&photoreference=$photoRef'
          '&key=${AppConstants.googleMapsApiKey}';
    } else {
      imageUrl = getLocationImageUrl(locationQuery) ??
          _getDefaultImageUrl(selectedTypes);
    }

    // Build stop names for description
    final stopNames =
        stops.map((s) => s['name'] as String? ?? 'Unknown').take(3).join(', ');

    return ExcursionEntity(
      id: '',
      name: destinationQuery != null && destinationQuery.isNotEmpty
          ? '$locationQuery → $destinationQuery'
          : 'Explore $locationQuery',
      description: 'Auto-generated route with ${stops.length} stops '
          'including $stopNames and more.',
      destination: destinationQuery ?? locationQuery,
      imageUrl: imageUrl,
      status: 'active',
      startDate: now,
      endDate: now.add(Duration(hours: stops.length * 2)),
      price: 0,
      rating: double.parse(avgRating.toStringAsFixed(1)),
      duration: '${stops.length * 2} hours',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Generate a mock excursion when API doesn't return results
  ExcursionEntity _generateMockExcursion({
    required String locationQuery,
    String? destinationQuery,
    required double radiusKm,
    required List<String> selectedTypes,
    required LatLng center,
    String? userId,
  }) {
    final now = DateTime.now();
    final typesStr = selectedTypes.take(3).join(', ');
    final rating = 4.0 + _random.nextDouble() * 0.9;
    final stops = 3 + _random.nextInt(3); // 3-5 stops

    // Get image for the location
    final imageUrl = getLocationImageUrl(locationQuery) ??
        getLocationImageUrl(destinationQuery ?? '') ??
        _getDefaultImageUrl(selectedTypes);

    // Generate mock stop names based on types
    final mockStops = _generateMockStopNames(selectedTypes, locationQuery);

    return ExcursionEntity(
      id: '',
      name: destinationQuery != null && destinationQuery.isNotEmpty
          ? '$locationQuery → $destinationQuery'
          : 'Explore $locationQuery',
      description: 'Custom route exploring $typesStr '
          'within ${radiusKm.toStringAsFixed(1)} km radius. '
          'Includes: $mockStops.',
      destination: destinationQuery ?? locationQuery,
      imageUrl: imageUrl,
      status: 'active',
      startDate: now,
      endDate: now.add(Duration(hours: stops * 2)),
      price: 0,
      rating: double.parse(rating.toStringAsFixed(1)),
      duration: '${stops * 2} hours',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Generate mock stop names based on selected types
  String _generateMockStopNames(List<String> types, String location) {
    final stopNames = <String>[];

    for (final type in types.take(3)) {
      switch (type.toLowerCase()) {
        case 'museum':
          stopNames.add('$location National Museum');
          break;
        case 'park':
          stopNames.add('Central Park');
          break;
        case 'cafe':
          stopNames.add('Historic Cafe District');
          break;
        case 'church':
          stopNames.add('$location Cathedral');
          break;
        case 'art gallery':
          stopNames.add('Modern Art Gallery');
          break;
        case 'zoo':
          stopNames.add('$location Zoo');
          break;
        case 'aquarium':
          stopNames.add('Ocean Aquarium');
          break;
        case 'gym':
          stopNames.add('Sports Complex');
          break;
        case 'store':
          stopNames.add('Shopping District');
          break;
        default:
          stopNames.add('Local Attraction');
      }
    }

    return stopNames.join(', ');
  }

  /// Map UI type names to Google Places API types
  String _mapTypeToPlacesType(String uiType) {
    switch (uiType.toLowerCase()) {
      case 'art gallery':
        return 'art_gallery';
      case 'museum':
        return 'museum';
      case 'store':
        return 'store';
      case 'church':
        return 'church';
      case 'cafe':
        return 'cafe';
      case 'park':
        return 'park';
      case 'gym':
        return 'gym';
      case 'zoo':
        return 'zoo';
      case 'aquarium':
        return 'aquarium';
      default:
        return 'tourist_attraction';
    }
  }

  /// Get a default image URL based on selected types
  String _getDefaultImageUrl(List<String> types) {
    final imageUrls = {
      'museum':
          'https://images.unsplash.com/photo-1554907984-15263bfd63bd?w=800',
      'park':
          'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?w=800',
      'cafe': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
      'church':
          'https://images.unsplash.com/photo-1548625149-fc4a29cf7092?w=800',
      'zoo':
          'https://images.unsplash.com/photo-1474511320723-9a56873571b7?w=800',
      'aquarium':
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
      'gym':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'art gallery':
          'https://images.unsplash.com/photo-1531913764164-f85c52e6e654?w=800',
      'store':
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
    };

    for (final type in types) {
      if (imageUrls.containsKey(type.toLowerCase())) {
        return imageUrls[type.toLowerCase()]!;
      }
    }

    return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800';
  }

  void dispose() {
    _client.close();
  }
}
