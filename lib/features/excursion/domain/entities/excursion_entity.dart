import 'package:equatable/equatable.dart';

/// Landmark point for excursion route
class LandmarkPoint extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? description;

  const LandmarkPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.description,
  });

  @override
  List<Object?> get props =>
      [id, name, latitude, longitude, imageUrl, description];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
        'description': description,
      };

  factory LandmarkPoint.fromJson(Map<String, dynamic> json) => LandmarkPoint(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        latitude: (json['latitude'] ?? 0).toDouble(),
        longitude: (json['longitude'] ?? 0).toDouble(),
        imageUrl: json['imageUrl'],
        description: json['description'],
      );
}

/// Excursion entity representing a travel destination/excursion
class ExcursionEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String destination;
  final String imageUrl;
  final String status; // active, stopped, completed
  final DateTime? startDate;
  final DateTime? endDate;
  final double price;
  final double rating;
  final String duration;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<LandmarkPoint> landmarks;
  final double? destinationLatitude;
  final double? destinationLongitude;

  const ExcursionEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.destination,
    required this.imageUrl,
    required this.status,
    this.startDate,
    this.endDate,
    required this.price,
    required this.rating,
    required this.duration,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.landmarks = const [],
    this.destinationLatitude,
    this.destinationLongitude,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        destination,
        imageUrl,
        status,
        startDate,
        endDate,
        price,
        rating,
        duration,
        userId,
        createdAt,
        updatedAt,
        landmarks,
        destinationLatitude,
        destinationLongitude,
      ];

  ExcursionEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? destination,
    String? imageUrl,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    double? price,
    double? rating,
    String? duration,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<LandmarkPoint>? landmarks,
    double? destinationLatitude,
    double? destinationLongitude,
  }) {
    return ExcursionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      landmarks: landmarks ?? this.landmarks,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
    );
  }
}
