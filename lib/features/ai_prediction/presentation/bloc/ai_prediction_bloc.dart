import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/usecases/predict_training_suitability.dart';
import '../../domain/usecases/check_ai_service_health.dart';
import '../../domain/utils/weather_feature_converter.dart';
import '../../../home_page/domain/entities/weather_data_entitie.dart';
import '../../../../core/usecases/usecase.dart';

/// BLoC for managing AI prediction state and events
///
/// This BLoC handles all the state management for AI prediction functionality,
/// including making predictions, checking service health, and managing loading states.
/// It follows the BLoC pattern for clean separation of business logic and UI.
class AiPredictionBloc extends Bloc<AiPredictionEvent, AiPredictionState> {
  /// Use case for making exercise suitability predictions
  final PredictTrainingSuitability predictTrainingSuitability;

  /// Use case for checking AI service health
  final CheckAiServiceHealth checkAiServiceHealth;

  AiPredictionBloc({
    required this.predictTrainingSuitability,
    required this.checkAiServiceHealth,
  }) : super(AiPredictionInitial()) {
    // Register event handlers
    on<PredictFromWeatherData>(_onPredictFromWeatherData);
    on<CheckServiceHealth>(_onCheckServiceHealth);
    on<ResetPrediction>(_onResetPrediction);
  }

  /// Handles the PredictFromWeatherData event
  ///
  /// This method converts weather data to features and makes a prediction
  /// using the AI model. It manages the loading state and handles any errors.
  Future<void> _onPredictFromWeatherData(
    PredictFromWeatherData event,
    Emitter<AiPredictionState> emit,
  ) async {
    // Emit loading state
    emit(AiPredictionLoading());

    try {
      // Convert weather data to AI model features
      final features = WeatherFeatureConverter.convertWeatherData(
        event.weatherData,
      );

      // Make the prediction using the use case
      final result = await predictTrainingSuitability(features);

      // Handle the result
      result.fold(
        (failure) => emit(AiPredictionError(failure.message)),
        (prediction) => emit(AiPredictionLoaded(prediction)),
      );
    } catch (e) {
      // Handle any unexpected errors
      emit(AiPredictionError('Unexpected error: ${e.toString()}'));
    }
  }

  /// Handles the CheckServiceHealth event
  ///
  /// This method checks if the AI service is available and ready to make predictions.
  /// It's useful for showing service status in the UI.
  Future<void> _onCheckServiceHealth(
    CheckServiceHealth event,
    Emitter<AiPredictionState> emit,
  ) async {
    // Emit loading state
    emit(AiPredictionLoading());

    try {
      // Check service health using the use case
      final result = await checkAiServiceHealth(NoParams());

      // Handle the result
      result.fold(
        (failure) =>
            emit(AiPredictionError('Service unavailable: ${failure.message}')),
        (isHealthy) => emit(AiServiceHealthChecked(isHealthy)),
      );
    } catch (e) {
      // Handle any unexpected errors
      emit(AiPredictionError('Health check failed: ${e.toString()}'));
    }
  }

  /// Handles the ResetPrediction event
  ///
  /// This method resets the prediction state back to initial state.
  /// Useful for clearing previous predictions or errors.
  void _onResetPrediction(
    ResetPrediction event,
    Emitter<AiPredictionState> emit,
  ) {
    emit(AiPredictionInitial());
  }
}

/// Base class for all AI prediction events
///
/// Events represent user actions or external triggers that can change
/// the state of the AI prediction feature.
abstract class AiPredictionEvent extends Equatable {
  const AiPredictionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger a prediction based on weather data
///
/// This event is fired when the user wants to get an AI prediction
/// about exercise suitability based on current weather conditions.
class PredictFromWeatherData extends AiPredictionEvent {
  /// The weather data to analyze for exercise suitability
  final WeatherData weatherData;

  const PredictFromWeatherData(this.weatherData);

  @override
  List<Object?> get props => [weatherData];
}

/// Event to check the health status of the AI service
///
/// This event is fired when the app wants to verify that the AI
/// prediction service is available and ready to make predictions.
class CheckServiceHealth extends AiPredictionEvent {
  const CheckServiceHealth();
}

/// Event to reset the prediction state
///
/// This event is fired when the user wants to clear the current
/// prediction result and return to the initial state.
class ResetPrediction extends AiPredictionEvent {
  const ResetPrediction();
}

/// Base class for all AI prediction states
///
/// States represent the current condition of the AI prediction feature
/// and determine what the UI should display.
abstract class AiPredictionState extends Equatable {
  const AiPredictionState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no prediction has been made yet
///
/// This is the default state when the feature is first loaded.
/// The UI should show an initial message and option to make a prediction.
class AiPredictionInitial extends AiPredictionState {
  const AiPredictionInitial();
}

/// State when a prediction request is in progress
///
/// This state is active while the AI model is processing the weather data
/// and making a prediction. The UI should show a loading indicator.
class AiPredictionLoading extends AiPredictionState {
  const AiPredictionLoading();
}

/// State when a prediction has been successfully completed
///
/// This state contains the prediction result from the AI model.
/// The UI should display the prediction details and result.
class AiPredictionLoaded extends AiPredictionState {
  /// The prediction result from the AI model
  final PredictionResult predictionResult;

  const AiPredictionLoaded(this.predictionResult);

  @override
  List<Object?> get props => [predictionResult];
}

/// State when a prediction request has failed
///
/// This state is active when an error occurred during prediction.
/// The UI should display the error message and option to retry.
class AiPredictionError extends AiPredictionState {
  /// The error message describing what went wrong
  final String message;

  const AiPredictionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when service health check has been completed
///
/// This state contains the result of checking whether the AI service
/// is healthy and ready to make predictions.
class AiServiceHealthChecked extends AiPredictionState {
  /// Whether the AI service is healthy and ready
  final bool isHealthy;

  const AiServiceHealthChecked(this.isHealthy);

  @override
  List<Object?> get props => [isHealthy];
}
