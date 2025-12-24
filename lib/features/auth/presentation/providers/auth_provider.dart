import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Auth state provider - listens to auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Current user provider
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.getCurrentUser();
      return result.fold(
        (failure) => null,
        (user) => user,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _repository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncValue.data(user);
        return true;
      },
    );
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String gender,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      gender: gender,
      phoneNumber: phoneNumber,
    );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncValue.data(user);
        return true;
      },
    );
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithGoogle();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncValue.data(user);
        return true;
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    final result = await _repository.resetPassword(email);
    return result.fold(
      (failure) => false,
      (_) => true,
    );
  }

  /// Update profile
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
    List<String>? preferences,
  }) async {
    final result = await _repository.updateProfile(
      name: name,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      preferences: preferences,
    );
    return result.fold(
      (failure) => false,
      (user) {
        state = AsyncValue.data(user);
        return true;
      },
    );
  }
}

/// Auth notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

