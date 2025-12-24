import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/excursion_entity.dart';

/// Data model for Excursion with JSON serialization
class ExcursionModel extends ExcursionEntity {
  const ExcursionModel({
    required super.id,
    required super.name,
    required super.description,
    required super.destination,
    required super.imageUrl,
    required super.status,
    super.startDate,
    super.endDate,
    required super.price,
    required super.rating,
    required super.duration,
    super.userId,
    required super.createdAt,
    required super.updatedAt,
    super.landmarks = const [],
    super.destinationLatitude,
    super.destinationLongitude,
  });

  /// Create from Firestore document
  factory ExcursionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse landmarks from Firestore
    List<LandmarkPoint> landmarks = [];
    if (data['landmarks'] != null) {
      landmarks = (data['landmarks'] as List)
          .map((l) => LandmarkPoint.fromJson(l as Map<String, dynamic>))
          .toList();
    }

    return ExcursionModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      destination: data['destination'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'active',
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      duration: data['duration'] ?? '',
      userId: data['userId'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      landmarks: landmarks,
      destinationLatitude: data['destinationLatitude']?.toDouble(),
      destinationLongitude: data['destinationLongitude']?.toDouble(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'destination': destination,
      'imageUrl': imageUrl,
      'status': status,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'price': price,
      'rating': rating,
      'duration': duration,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'landmarks': landmarks.map((l) => l.toJson()).toList(),
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
    };
  }

  /// Create from entity
  factory ExcursionModel.fromEntity(ExcursionEntity entity) {
    return ExcursionModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      destination: entity.destination,
      imageUrl: entity.imageUrl,
      status: entity.status,
      startDate: entity.startDate,
      endDate: entity.endDate,
      price: entity.price,
      rating: entity.rating,
      duration: entity.duration,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      landmarks: entity.landmarks,
      destinationLatitude: entity.destinationLatitude,
      destinationLongitude: entity.destinationLongitude,
    );
  }

  /// Convert to entity
  ExcursionEntity toEntity() {
    return ExcursionEntity(
      id: id,
      name: name,
      description: description,
      destination: destination,
      imageUrl: imageUrl,
      status: status,
      startDate: startDate,
      endDate: endDate,
      price: price,
      rating: rating,
      duration: duration,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      landmarks: landmarks,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
    );
  }
}
