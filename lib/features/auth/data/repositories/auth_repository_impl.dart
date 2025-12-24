import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Auth repository implementation - data layer
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId:
                  '968321116168-dhm3pguhspbrn4u9khqj2nhv51oc1hcr.apps.googleusercontent.com',
              scopes: ['email', 'profile'],
            );

  /// Users collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AppConstants.usersCollection);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final userData = await _getUserData(user.uid);
      return userData;
    });
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'No user logged in'));
      }
      final userData = await _getUserData(user.uid);
      if (userData == null) {
        return const Left(AuthFailure(message: 'User data not found'));
      }
      return Right(userData);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const Left(AuthFailure(message: 'Sign in failed'));
      }

      final userData = await _getUserData(user.uid);
      if (userData == null) {
        return const Left(AuthFailure(message: 'User data not found'));
      }

      return Right(userData);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String gender,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const Left(AuthFailure(message: 'Sign up failed'));
      }

      // Update display name
      await user.updateDisplayName(name);

      // Parse gender string to enum
      final genderEnum = gender == 'male' ? Gender.male : Gender.female;

      // Create user model
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        photoUrl: user.photoURL,
        role: UserRole.tourist,
        gender: genderEnum,
        preferences: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _usersCollection.doc(user.uid).set(userModel.toFirestore());

      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure(message: 'Google sign in cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return const Left(AuthFailure(message: 'Google sign in failed'));
      }

      // Check if user exists in Firestore
      final userDoc = await _usersCollection.doc(user.uid).get();

      if (!userDoc.exists) {
        // Create new user
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber,
          photoUrl: user.photoURL,
          role: UserRole.tourist,
          preferences: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _usersCollection.doc(user.uid).set(userModel.toFirestore());
        return Right(userModel.toEntity());
      }

      final userData = UserModel.fromFirestore(userDoc);
      return Right(userData.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
    List<String>? preferences,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'No user logged in'));
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updates['name'] = name;
        await user.updateDisplayName(name);
      }
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
        await user.updatePhotoURL(photoUrl);
      }
      if (preferences != null) updates['preferences'] = preferences;

      await _usersCollection.doc(user.uid).update(updates);

      final userData = await _getUserData(user.uid);
      if (userData == null) {
        return const Left(AuthFailure(message: 'User data not found'));
      }

      return Right(userData);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'No user logged in'));
      }

      // Delete user data from Firestore
      await _usersCollection.doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserStats({
    int? incrementTrips,
    double? addKmTraveled,
    int? incrementPlaces,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'No user logged in'));
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Use FieldValue.increment for atomic updates
      if (incrementTrips != null && incrementTrips > 0) {
        updates['tripsCount'] = FieldValue.increment(incrementTrips);
      }
      if (addKmTraveled != null && addKmTraveled > 0) {
        updates['kmTraveled'] = FieldValue.increment(addKmTraveled);
      }
      if (incrementPlaces != null && incrementPlaces > 0) {
        updates['placesVisited'] = FieldValue.increment(incrementPlaces);
      }

      if (updates.length > 1) {
        // More than just updatedAt
        await _usersCollection.doc(user.uid).update(updates);
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(message: e.message ?? 'Firebase error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get user data from Firestore
  Future<UserEntity?> _getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc).toEntity();
    } catch (e) {
      return null;
    }
  }
}
