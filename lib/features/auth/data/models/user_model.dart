import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// User model - data layer
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phoneNumber,
    super.photoUrl,
    super.role,
    super.gender,
    super.preferences,
    super.createdAt,
    super.updatedAt,
    super.tripsCount,
    super.kmTraveled,
    super.placesVisited,
  });

  /// Create from Firebase User
  factory UserModel.fromFirebaseUser(
    dynamic firebaseUser, {
    String? displayName,
    String? phoneNumber,
    UserRole role = UserRole.tourist,
    Gender? gender,
    List<String> preferences = const [],
  }) {
    return UserModel(
      uid: firebaseUser.uid as String,
      name: displayName ?? firebaseUser.displayName as String? ?? '',
      email: firebaseUser.email as String? ?? '',
      phoneNumber: phoneNumber ?? firebaseUser.phoneNumber as String?,
      photoUrl: firebaseUser.photoURL as String?,
      role: role,
      gender: gender,
      preferences: preferences,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: _parseRole(data['role'] as String?),
      gender: _parseGender(data['gender'] as String?),
      preferences: List<String>.from(data['preferences'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      // Profile statistics from Firestore
      tripsCount: (data['tripsCount'] as num?)?.toInt() ?? 0,
      kmTraveled: (data['kmTraveled'] as num?)?.toDouble() ?? 0.0,
      placesVisited: (data['placesVisited'] as num?)?.toInt() ?? 0,
    );
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: _parseRole(json['role'] as String?),
      gender: _parseGender(json['gender'] as String?),
      preferences: List<String>.from(json['preferences'] as List? ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      tripsCount: (json['tripsCount'] as num?)?.toInt() ?? 0,
      kmTraveled: (json['kmTraveled'] as num?)?.toDouble() ?? 0.0,
      placesVisited: (json['placesVisited'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role.name,
      'gender': gender?.name,
      'preferences': preferences,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tripsCount': tripsCount,
      'kmTraveled': kmTraveled,
      'placesVisited': placesVisited,
    };
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role.name,
      'gender': gender?.name,
      'preferences': preferences,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'tripsCount': tripsCount,
      'kmTraveled': kmTraveled,
      'placesVisited': placesVisited,
    };
  }

  /// Parse role from string
  static UserRole _parseRole(String? roleStr) {
    if (roleStr == 'moderator') return UserRole.moderator;
    return UserRole.tourist;
  }

  /// Parse gender from string
  static Gender? _parseGender(String? genderStr) {
    if (genderStr == 'male') return Gender.male;
    if (genderStr == 'female') return Gender.female;
    return null;
  }

  /// Convert entity to model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      photoUrl: entity.photoUrl,
      role: entity.role,
      gender: entity.gender,
      preferences: entity.preferences,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      tripsCount: entity.tripsCount,
      kmTraveled: entity.kmTraveled,
      placesVisited: entity.placesVisited,
    );
  }

  /// Convert to entity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      role: role,
      gender: gender,
      preferences: preferences,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tripsCount: tripsCount,
      kmTraveled: kmTraveled,
      placesVisited: placesVisited,
    );
  }
}
