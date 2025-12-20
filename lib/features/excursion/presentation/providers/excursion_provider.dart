import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/excursion_entity.dart';
import '../../domain/repositories/excursion_repository.dart';
import '../../data/repositories/excursion_repository_impl.dart';
import '../../data/datasources/excursion_remote_datasource.dart';

/// Provider for excursion remote data source
final excursionRemoteDataSourceProvider =
    Provider<ExcursionRemoteDataSource>((ref) {
  return ExcursionRemoteDataSourceImpl();
});

/// Provider for excursion repository
final excursionRepositoryProvider = Provider<ExcursionRepository>((ref) {
  return ExcursionRepositoryImpl(
    remoteDataSource: ref.read(excursionRemoteDataSourceProvider),
  );
});

/// State for excursions list
class ExcursionsState {
  final List<ExcursionEntity> excursions;
  final bool isLoading;
  final String? error;

  const ExcursionsState({
    this.excursions = const [],
    this.isLoading = false,
    this.error,
  });

  ExcursionsState copyWith({
    List<ExcursionEntity>? excursions,
    bool? isLoading,
    String? error,
  }) {
    return ExcursionsState(
      excursions: excursions ?? this.excursions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for excursions state management
class ExcursionsNotifier extends StateNotifier<ExcursionsState> {
  final ExcursionRepository _repository;

  ExcursionsNotifier(this._repository) : super(const ExcursionsState());

  /// Load all excursions
  Future<void> loadExcursions() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getExcursions();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (excursions) => state = state.copyWith(
        isLoading: false,
        excursions: excursions,
      ),
    );
  }

  /// Load popular excursions
  Future<void> loadPopularExcursions({int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getPopularExcursions(limit: limit);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (excursions) => state = state.copyWith(
        isLoading: false,
        excursions: excursions,
      ),
    );
  }

  /// Search excursions
  Future<void> searchExcursions(String query) async {
    if (query.isEmpty) {
      await loadPopularExcursions();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.searchExcursions(query);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (excursions) => state = state.copyWith(
        isLoading: false,
        excursions: excursions,
      ),
    );
  }

  /// Create excursion
  Future<bool> createExcursion(ExcursionEntity excursion) async {
    final result = await _repository.createExcursion(excursion);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (created) {
        state = state.copyWith(
          excursions: [created, ...state.excursions],
        );
        return true;
      },
    );
  }

  /// Delete excursion
  Future<bool> deleteExcursion(String id) async {
    final result = await _repository.deleteExcursion(id);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          excursions:
              state.excursions.where((e) => e.id != id).toList(),
        );
        return true;
      },
    );
  }
}

/// Provider for excursions state
final excursionsProvider =
    StateNotifierProvider<ExcursionsNotifier, ExcursionsState>((ref) {
  return ExcursionsNotifier(ref.read(excursionRepositoryProvider));
});

/// Provider for popular excursions (auto-load)
final popularExcursionsProvider = FutureProvider<List<ExcursionEntity>>((ref) async {
  final repository = ref.read(excursionRepositoryProvider);
  final result = await repository.getPopularExcursions(limit: 10);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (excursions) => excursions,
  );
});

/// Provider for single excursion by ID
final excursionByIdProvider =
    FutureProvider.family<ExcursionEntity, String>((ref, id) async {
  final repository = ref.read(excursionRepositoryProvider);
  final result = await repository.getExcursionById(id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (excursion) => excursion,
  );
});

