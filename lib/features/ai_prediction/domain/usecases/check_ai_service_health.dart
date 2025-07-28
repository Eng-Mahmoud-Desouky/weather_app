import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/ai_prediction_repository.dart';

/// Use case for checking the health status of the AI prediction service
///
/// This use case encapsulates the business logic for verifying that the
/// AI model server is available and ready to make predictions. It's useful for:
/// - Displaying service status in the UI
/// - Implementing graceful degradation when the service is unavailable
/// - Health monitoring and diagnostics
/// - Deciding whether to show AI prediction features to users
///
/// Following Clean Architecture principles, this use case contains the
/// business rules for determining service health and is independent of
/// external frameworks.
class CheckAiServiceHealth implements UseCase<bool, NoParams> {
  /// Repository for AI prediction operations
  /// Injected through constructor for dependency inversion
  final AiPredictionRepository repository;

  const CheckAiServiceHealth(this.repository);

  /// Executes the health check use case
  ///
  /// This method contains the business logic for determining if the AI
  /// prediction service is healthy and ready to accept requests. It:
  /// 1. Delegates to the repository to check service availability
  /// 2. Applies business rules to determine overall health status
  /// 3. Returns a boolean indicating service readiness
  ///
  /// Parameters:
  /// - [params]: No parameters needed (uses NoParams)
  ///
  /// Returns:
  /// - [Right(true)]: Service is healthy and ready for predictions
  /// - [Right(false)]: Service is reachable but not ready (e.g., model not loaded)
  /// - [Left(Failure)]: Service is unreachable or error occurred
  ///
  /// Business Rules Applied:
  /// - Service must be reachable via network
  /// - AI model must be loaded and ready
  /// - Response time should be reasonable (handled by repository)
  ///
  /// Example usage:
  /// ```dart
  /// final useCase = CheckAiServiceHealth(repository);
  /// final result = await useCase(NoParams());
  ///
  /// result.fold(
  ///   (failure) => showError('AI service unavailable: ${failure.message}'),
  ///   (isHealthy) => isHealthy
  ///     ? enableAiFeatures()
  ///     : showWarning('AI service not ready'),
  /// );
  /// ```
  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    // Delegate to repository for the actual health check
    final healthResult = await repository.checkServiceHealth();

    // Apply business rules to determine final health status
    return healthResult.fold(
      (failure) => Left(_enhanceHealthFailure(failure)),
      (isHealthy) => Right(_validateHealthStatus(isHealthy)),
    );
  }

  /// Enhances health check failures with additional context
  ///
  /// This method can add business logic to health check failures,
  /// such as providing more user-friendly error messages or
  /// categorizing different types of health check failures.
  Failure _enhanceHealthFailure(Failure failure) {
    // Add business context to the failure
    // For example, you could categorize failures or provide
    // more user-friendly messages based on the failure type

    if (failure is NetworkFailure) {
      return const ServiceUnavailableFailure(
        'AI prediction service is currently unavailable. Please check your internet connection.',
      );
    }

    if (failure is ServerFailure) {
      return const ServiceUnavailableFailure(
        'AI prediction service is experiencing issues. Please try again later.',
      );
    }

    // Return the original failure if no specific enhancement is needed
    return failure;
  }

  /// Validates and potentially modifies the health status
  ///
  /// This method applies business rules to the health status returned
  /// by the repository. For example, you might want to consider the
  /// service unhealthy if certain conditions are not met.
  bool _validateHealthStatus(bool isHealthy) {
    // Apply any additional business rules for health validation
    // For now, we trust the repository's health assessment

    // In the future, you could add logic such as:
    // - Check if the service has been healthy for a minimum duration
    // - Verify that recent predictions have been successful
    // - Ensure response times are within acceptable limits

    return isHealthy;
  }
}
