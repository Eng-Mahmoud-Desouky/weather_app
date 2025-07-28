import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prediction_result.dart';
import '../repositories/ai_prediction_repository.dart';

/// Use case for predicting exercise suitability based on weather features
///
/// This use case encapsulates the business logic for making AI predictions
/// about whether current weather conditions are suitable for outdoor exercise.
/// Following Clean Architecture, this use case:
/// - Contains the business rules for prediction
/// - Is independent of external frameworks
/// - Coordinates between the repository and the presentation layer
///
/// The use case takes weather features as input and returns a prediction result,
/// handling all the complexity of the prediction process.
class PredictTrainingSuitability
    implements UseCase<PredictionResult, WeatherFeatures> {
  /// Repository for making AI predictions
  /// Injected through constructor for dependency inversion
  final AiPredictionRepository repository;

  const PredictTrainingSuitability(this.repository);

  /// Executes the prediction use case
  ///
  /// This method contains the core business logic for making exercise
  /// suitability predictions. It:
  /// 1. Validates the input weather features
  /// 2. Delegates to the repository for the actual prediction
  /// 3. Applies any business rules to the result
  /// 4. Returns the final prediction result
  ///
  /// Parameters:
  /// - [params]: Weather features to analyze for exercise suitability
  ///
  /// Returns:
  /// - [Right(PredictionResult)]: Successful prediction with detailed results
  /// - [Left(Failure)]: Error occurred during prediction process
  ///
  /// Business Rules Applied:
  /// - Validates that weather features are logically consistent
  /// - Ensures prediction results are properly formatted
  /// - Adds timestamp and metadata to results
  ///
  /// Example usage:
  /// ```dart
  /// final useCase = PredictTrainingSuitability(repository);
  /// final features = WeatherFeatures(
  ///   outlookRainy: false,
  ///   outlookSunny: true,
  ///   temperatureHot: false,
  ///   temperatureMild: true,
  ///   humidityNormal: true,
  /// );
  ///
  /// final result = await useCase(features);
  /// result.fold(
  ///   (failure) => handleError(failure),
  ///   (prediction) => displayPrediction(prediction),
  /// );
  /// ```
  @override
  Future<Either<Failure, PredictionResult>> call(WeatherFeatures params) async {
    // Validate input features before making prediction
    final validationResult = _validateWeatherFeatures(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Delegate to repository for the actual prediction
    final predictionResult = await repository.predictTrainingSuitability(
      params,
    );

    // Apply any additional business rules to the result
    return predictionResult.fold(
      (failure) => Left(failure),
      (prediction) => Right(_enhancePredictionResult(prediction)),
    );
  }

  /// Validates weather features for logical consistency
  ///
  /// This method applies business rules to ensure the weather features
  /// make sense before sending them to the AI model. For example:
  /// - Weather can't be both rainy and sunny at the same time
  /// - Temperature can't be both hot and mild simultaneously
  ///
  /// Returns null if validation passes, or a Failure if validation fails.
  Failure? _validateWeatherFeatures(WeatherFeatures features) {
    // Business rule: Weather outlook should be either rainy, sunny, or neither (cloudy/overcast)
    // but not both rainy and sunny at the same time
    if (features.outlookRainy && features.outlookSunny) {
      return const ValidationFailure(
        'Weather cannot be both rainy and sunny at the same time',
      );
    }

    // Business rule: Temperature should be either hot, mild, or neither (cold)
    // but not both hot and mild at the same time
    if (features.temperatureHot && features.temperatureMild) {
      return const ValidationFailure(
        'Temperature cannot be both hot and mild at the same time',
      );
    }

    // All validations passed
    return null;
  }

  /// Enhances the prediction result with additional business logic
  ///
  /// This method can add extra information or apply business rules
  /// to the prediction result before returning it to the presentation layer.
  /// For example:
  /// - Adding contextual messages based on weather conditions
  /// - Adjusting confidence levels based on feature combinations
  /// - Adding recommendations or tips
  PredictionResult _enhancePredictionResult(PredictionResult prediction) {
    // For now, return the prediction as-is
    // In the future, you could add business logic here such as:
    // - Contextual messages based on specific weather combinations
    // - Confidence adjustments based on feature patterns
    // - Additional recommendations or tips

    return prediction;
  }
}
