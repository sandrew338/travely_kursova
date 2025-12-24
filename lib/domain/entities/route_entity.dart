import 'package:equatable/equatable.dart';

import '../../features/excursion/domain/entities/excursion_entity.dart';
import 'audio_entity.dart';
import 'enums.dart';

/// Route entity - domain layer
class RouteEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<LandmarkPoint> points;
  final double totalDistance;
  final Duration estimatedDuration;
  final RouteDifficulty difficulty;
  final TransportType transportType;
  final double rating;
  final List<AudioEntity>? audios;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? creatorId;

  const RouteEntity({
    required this.id,
    required this.name,
    required this.description,
    this.points = const [],
    required this.totalDistance,
    required this.estimatedDuration,
    required this.difficulty,
    required this.transportType,
    this.rating = 0.0,
    this.audios,
    this.isPublic = false,
    this.createdAt,
    this.updatedAt,
    this.creatorId,
  });

  /// Empty route
  static const empty = RouteEntity(
    id: '',
    name: '',
    description: '',
    points: [],
    totalDistance: 0.0,
    estimatedDuration: Duration.zero,
    difficulty: RouteDifficulty.easy,
    transportType: TransportType.walking,
    rating: 0.0,
    isPublic: false,
  );

  /// Check if route is empty
  bool get isEmpty => id.isEmpty;

  /// Check if route is not empty
  bool get isNotEmpty => id.isNotEmpty;

  /// Check if route has audio guides
  bool get hasAudioGuides => audios != null && audios!.isNotEmpty;

  /// Get number of points/stops
  int get pointsCount => points.length;

  /// Get formatted distance (e.g., "2.5 км")
  String get formattedDistance {
    if (totalDistance < 1) {
      return '${(totalDistance * 1000).toStringAsFixed(0)} м';
    }
    return '${totalDistance.toStringAsFixed(1)} км';
  }

  /// Get formatted duration (e.g., "2 год 30 хв")
  String get formattedDuration {
    final hours = estimatedDuration.inHours;
    final minutes = estimatedDuration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours год $minutes хв';
    } else if (hours > 0) {
      return '$hours год';
    } else {
      return '$minutes хв';
    }
  }

  /// Get formatted rating (e.g., "4.5")
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get start point (first landmark)
  LandmarkPoint? get startPoint => points.isNotEmpty ? points.first : null;

  /// Get end point (last landmark)
  LandmarkPoint? get endPoint => points.isNotEmpty ? points.last : null;

  /// Calculate estimated duration based on distance and transport type
  static Duration calculateEstimatedDuration(
    double distanceKm,
    TransportType transport,
  ) {
    final hours = distanceKm / transport.averageSpeedKmh;
    return Duration(minutes: (hours * 60).round());
  }

  /// Copy with method
  RouteEntity copyWith({
    String? id,
    String? name,
    String? description,
    List<LandmarkPoint>? points,
    double? totalDistance,
    Duration? estimatedDuration,
    RouteDifficulty? difficulty,
    TransportType? transportType,
    double? rating,
    List<AudioEntity>? audios,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creatorId,
  }) {
    return RouteEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      points: points ?? this.points,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      difficulty: difficulty ?? this.difficulty,
      transportType: transportType ?? this.transportType,
      rating: rating ?? this.rating,
      audios: audios ?? this.audios,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        points,
        totalDistance,
        estimatedDuration,
        difficulty,
        transportType,
        rating,
        audios,
        isPublic,
        createdAt,
        updatedAt,
        creatorId,
      ];
}

