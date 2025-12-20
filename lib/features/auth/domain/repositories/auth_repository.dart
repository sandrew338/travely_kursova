import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Auth repository interface - domain layer
abstract class AuthRepository {
  /// Get current user stream
  Stream<UserEntity?> get authStateChanges;

  /// Get current user
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  });

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Reset password
  Future<Either<Failure, void>> resetPassword(String email);

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
    List<String>? preferences,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();
}

