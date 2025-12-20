import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/excursion_entity.dart';

/// Abstract repository for excursion operations
abstract class ExcursionRepository {
  /// Get all excursions
  Future<Either<Failure, List<ExcursionEntity>>> getExcursions();

  /// Get popular excursions (sorted by rating)
  Future<Either<Failure, List<ExcursionEntity>>> getPopularExcursions({
    int limit = 10,
  });

  /// Get excursion by ID
  Future<Either<Failure, ExcursionEntity>> getExcursionById(String id);

  /// Get excursions by user ID
  Future<Either<Failure, List<ExcursionEntity>>> getUserExcursions(
    String userId,
  );

  /// Create new excursion
  Future<Either<Failure, ExcursionEntity>> createExcursion(
    ExcursionEntity excursion,
  );

  /// Update excursion
  Future<Either<Failure, ExcursionEntity>> updateExcursion(
    ExcursionEntity excursion,
  );

  /// Delete excursion
  Future<Either<Failure, void>> deleteExcursion(String id);

  /// Search excursions by name or destination
  Future<Either<Failure, List<ExcursionEntity>>> searchExcursions(
    String query,
  );
}

