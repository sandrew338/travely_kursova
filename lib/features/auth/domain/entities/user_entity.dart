import 'package:equatable/equatable.dart';

/// User role enum
enum UserRole { tourist, moderator }

/// User entity - domain layer
class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final UserRole role;
  final List<String> preferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.role = UserRole.tourist,
    this.preferences = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Empty user
  static const empty = UserEntity(
    uid: '',
    name: '',
    email: '',
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
    List<String>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        preferences,
        createdAt,
        updatedAt,
      ];
}
