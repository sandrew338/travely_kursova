import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/excursion_entity.dart';
import '../../domain/repositories/excursion_repository.dart';
import '../datasources/excursion_remote_datasource.dart';
import '../models/excursion_model.dart';

/// Implementation of ExcursionRepository
class ExcursionRepositoryImpl implements ExcursionRepository {
  final ExcursionRemoteDataSource remoteDataSource;

  ExcursionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ExcursionEntity>>> getExcursions() async {
    try {
      final excursions = await remoteDataSource.getExcursions();
      return Right(excursions.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExcursionEntity>>> getPopularExcursions({
    int limit = 10,
  }) async {
    try {
      final excursions =
          await remoteDataSource.getPopularExcursions(limit: limit);
      return Right(excursions.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExcursionEntity>> getExcursionById(String id) async {
    try {
      final excursion = await remoteDataSource.getExcursionById(id);
      return Right(excursion.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExcursionEntity>>> getUserExcursions(
    String userId,
  ) async {
    try {
      final excursions = await remoteDataSource.getUserExcursions(userId);
      return Right(excursions.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExcursionEntity>> createExcursion(
    ExcursionEntity excursion,
  ) async {
    try {
      final model = ExcursionModel.fromEntity(excursion);
      final created = await remoteDataSource.createExcursion(model);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExcursionEntity>> updateExcursion(
    ExcursionEntity excursion,
  ) async {
    try {
      final model = ExcursionModel.fromEntity(excursion);
      final updated = await remoteDataSource.updateExcursion(model);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExcursion(String id) async {
    try {
      await remoteDataSource.deleteExcursion(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExcursionEntity>>> searchExcursions(
    String query,
  ) async {
    try {
      final excursions = await remoteDataSource.searchExcursions(query);
      return Right(excursions.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}

