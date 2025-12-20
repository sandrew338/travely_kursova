import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
    super.code,
  });
}

/// Firebase failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    super.message = 'Firebase error occurred',
    super.code,
  });

  factory FirebaseFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const FirebaseFailure(message: 'No user found with this email');
      case 'wrong-password':
        return const FirebaseFailure(message: 'Wrong password');
      case 'email-already-in-use':
        return const FirebaseFailure(
          message: 'Email is already registered',
        );
      case 'invalid-email':
        return const FirebaseFailure(message: 'Invalid email address');
      case 'weak-password':
        return const FirebaseFailure(message: 'Password is too weak');
      case 'operation-not-allowed':
        return const FirebaseFailure(message: 'Operation not allowed');
      case 'user-disabled':
        return const FirebaseFailure(message: 'User account is disabled');
      default:
        return FirebaseFailure(message: 'Firebase error: $code', code: code);
    }
  }
}

/// Location failures
class LocationFailure extends Failure {
  const LocationFailure({
    super.message = 'Location error occurred',
    super.code,
  });
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied',
    super.code,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

