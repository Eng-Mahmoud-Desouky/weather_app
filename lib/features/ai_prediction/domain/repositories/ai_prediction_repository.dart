import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction_result.dart';

/// Abstract repository interface for AI prediction functionality
///
/// This repository defines the contract for making AI predictions about
/// exercise suitability based on weather conditions. Following Clean Architecture,
/// this interface is defined in the domain layer and implemented in the data layer.
///
/// The repository abstracts away the details of how predictions are made
/// (whether from a local model, remote API, cached results, etc.) and provides
/// a clean interface for the business logic layer.
abstract class AiPredictionRepository {
  /// Makes a prediction about exercise suitability based on weather features
  ///
  /// Takes weather features as input and returns either a successful prediction
  /// result or a failure. This method handles all the complexity of:
  /// - Converting weather features to the format expected by the AI model
  /// - Making the actual prediction request
  /// - Handling any errors that might occur
  /// - Converting the response back to domain entities
  ///
  /// Parameters:
  /// - [features]: The weather features to analyze for exercise suitability
  ///
  /// Returns:
  /// - [Right(PredictionResult)]: Successful prediction with result details
  /// - [Left(Failure)]: Error occurred during prediction (network, server, etc.)
  ///
  /// Example usage:
  /// ```dart
  /// final features = WeatherFeatures(
  ///   outlookRainy: false,
  ///   outlookSunny: true,
  ///   temperatureHot: false,
  ///   temperatureMild: true,
  ///   humidityNormal: true,
  /// );
  ///
  /// final result = await repository.predictTrainingSuitability(features);
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (prediction) => print('Suitable: ${prediction.suitableForTraining}'),
  /// );
  /// ```
  Future<Either<Failure, PredictionResult>> predictTrainingSuitability(
    WeatherFeatures features,
  );

  /// Checks if the AI prediction service is available and healthy
  ///
  /// This method can be used to verify that the AI model server is running
  /// and ready to accept prediction requests. Useful for:
  /// - Showing service status in the UI
  /// - Graceful degradation when service is unavailable
  /// - Health monitoring and diagnostics
  ///
  /// Returns:
  /// - [Right(true)]: Service is healthy and available
  /// - [Right(false)]: Service is running but not ready (e.g., model not loaded)
  /// - [Left(Failure)]: Service is unreachable or error occurred
  ///
  /// Example usage:
  /// ```dart
  /// final healthResult = await repository.checkServiceHealth();
  /// healthResult.fold(
  ///   (failure) => showError('AI service unavailable'),
  ///   (isHealthy) => isHealthy
  ///     ? showSuccess('AI service ready')
  ///     : showWarning('AI service not ready'),
  /// );
  /// ```
  Future<Either<Failure, bool>> checkServiceHealth();
}
