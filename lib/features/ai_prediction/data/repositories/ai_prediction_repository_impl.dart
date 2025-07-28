import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/ai_prediction_repository.dart';
import '../datasources/ai_prediction_remote_data_source.dart';

/// Implementation of the AI prediction repository
///
/// This class implements the repository interface defined in the domain layer
/// and coordinates between the domain layer and the data sources. It's responsible for:
/// - Converting between domain entities and data models
/// - Handling exceptions from data sources and converting them to domain failures
/// - Implementing caching strategies (if needed in the future)
/// - Coordinating multiple data sources (remote API, local cache, etc.)
///
/// Following Clean Architecture, this repository implementation is in the data layer
/// and depends on abstractions (interfaces) rather than concrete implementations.
class AiPredictionRepositoryImpl implements AiPredictionRepository {
  /// Remote data source for AI prediction API communication
  /// Injected through constructor for dependency inversion and testing
  final AiPredictionRemoteDataSource remoteDataSource;

  const AiPredictionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PredictionResult>> predictTrainingSuitability(
    WeatherFeatures features,
  ) async {
    try {
      // Delegate to the remote data source for the actual API call
      final predictionResult = await remoteDataSource
          .predictTrainingSuitability(features);

      // Return the successful result wrapped in Right
      // The data source already returns a domain entity (PredictionResponseModel extends PredictionResult)
      return Right(predictionResult);
    } on ServerException catch (e) {
      // Convert server exceptions to domain failures
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Convert network exceptions to domain failures
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      // Convert timeout exceptions to domain failures
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      // Handle any unexpected exceptions
      return Left(
        UnknownFailure('Unexpected error during prediction: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> checkServiceHealth() async {
    try {
      // Delegate to the remote data source for the health check
      final isHealthy = await remoteDataSource.checkServiceHealth();

      // Return the successful result wrapped in Right
      return Right(isHealthy);
    } on ServerException catch (e) {
      // Convert server exceptions to domain failures
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Convert network exceptions to domain failures
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      // Convert timeout exceptions to domain failures
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      // Handle any unexpected exceptions
      return Left(
        UnknownFailure('Unexpected error during health check: ${e.toString()}'),
      );
    }
  }
}
