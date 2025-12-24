import 'package:equatable/equatable.dart';

/// User role enum
enum UserRole { tourist, moderator }

/// Gender enum
enum Gender { male, female }

/// User entity - domain layer
class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final UserRole role;
  final Gender? gender;
  final List<String> preferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Profile statistics fields
  final int tripsCount;
  final double kmTraveled;
  final int placesVisited;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.role = UserRole.tourist,
    this.gender,
    this.preferences = const [],
    this.createdAt,
    this.updatedAt,
    this.tripsCount = 0,
    this.kmTraveled = 0.0,
    this.placesVisited = 0,
  });

  /// Empty user
  static const empty = UserEntity(
    uid: '',
    name: '',
    email: '',
    gender: null,
    tripsCount: 0,
    kmTraveled: 0.0,
    placesVisited: 0,
  );

  /// Check if user is empty
  bool get isEmpty => this == UserEntity.empty;

  /// Check if user is not empty
  bool get isNotEmpty => this != UserEntity.empty;

  /// Check if user is moderator
  bool get isModerator => role == UserRole.moderator;

  /// Check if user is tourist
  bool get isTourist => role == UserRole.tourist;

  /// Copy with method
  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    UserRole? role,
    Gender? gender,
    List<String>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? tripsCount,
    double? kmTraveled,
    int? placesVisited,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tripsCount: tripsCount ?? this.tripsCount,
      kmTraveled: kmTraveled ?? this.kmTraveled,
      placesVisited: placesVisited ?? this.placesVisited,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        phoneNumber,
        photoUrl,
        role,
        gender,
        preferences,
        createdAt,
        updatedAt,
        tripsCount,
        kmTraveled,
        placesVisited,
      ];
}
