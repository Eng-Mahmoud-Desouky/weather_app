import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home_page/domain/entities/weather_data_entitie.dart';
import '../bloc/ai_prediction_bloc.dart';
import 'ai_prediction_card.dart';
import '../../../../core/di/injection_container.dart' as di;

/// Main AI Prediction Widget that integrates with BLoC
///
/// This widget serves as the main entry point for the AI prediction feature.
/// It manages the BLoC state and provides the weather data to make predictions.
/// This is the widget that should be used in the home page to display AI predictions.
///
/// The widget automatically handles:
/// - State management through BLoC
/// - Converting weather data to AI features
/// - Displaying appropriate UI based on current state
/// - Error handling and retry functionality
///
/// Usage in home page:
/// ```dart
/// AiPredictionWidget(weatherData: currentWeatherData)
/// ```
class AiPredictionWidget extends StatelessWidget {
  /// The current weather data to analyze for training suitability
  /// This data comes from the home_page feature and gets converted
  /// to the binary features required by the AI model
  final WeatherData? weatherData;

  /// Whether to automatically make a prediction when weather data is available
  /// If true, the widget will automatically trigger a prediction when weatherData changes
  /// If false, the user must manually trigger predictions
  final bool autoPredict;

  const AiPredictionWidget({
    super.key,
    this.weatherData,
    this.autoPredict = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiPredictionBloc, AiPredictionState>(
      builder: (context, state) {
        // Determine the current state for the UI
        final isLoading = state is AiPredictionLoading;
        final errorMessage = state is AiPredictionError ? state.message : null;
        final predictionResult =
            state is AiPredictionLoaded ? state.predictionResult : null;

        return AiPredictionCard(
          predictionResult: predictionResult,
          weatherData: weatherData,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh:
              weatherData != null ? () => _makePrediction(context) : null,
        );
      },
    );
  }

  /// Triggers a new AI prediction based on current weather data
  ///
  /// This method sends a PredictFromWeatherData event to the BLoC
  /// which will convert the weather data to features and make a prediction.
  void _makePrediction(BuildContext context) {
    if (weatherData != null) {
      context.read<AiPredictionBloc>().add(
        PredictFromWeatherData(weatherData!),
      );
    }
  }
}

/// Widget that provides the AI Prediction BLoC to its children
///
/// This widget should wrap the AiPredictionWidget to provide the necessary
/// BLoC instance. It handles the dependency injection for the AI prediction feature.
///
/// Usage:
/// ```dart
/// AiPredictionProvider(
///   child: AiPredictionWidget(weatherData: weatherData),
/// )
/// ```
class AiPredictionProvider extends StatelessWidget {
  /// The child widget that will have access to the AI Prediction BLoC
  final Widget child;

  const AiPredictionProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiPredictionBloc>(
      create: (context) => di.sl<AiPredictionBloc>(),
      child: child,
    );
  }
}

/// Convenience widget that combines provider and widget
///
/// This widget provides a simple way to add AI prediction functionality
/// to any screen. It handles both the BLoC provider and the main widget.
///
/// Usage in home page:
/// ```dart
/// Column(
///   children: [
///     WeatherCard(weatherData: currentWeather),
///     SizedBox(height: 16),
///     AiPredictionFeature(weatherData: currentWeather),
///   ],
/// )
/// ```
class AiPredictionFeature extends StatelessWidget {
  /// The current weather data to analyze
  final WeatherData? weatherData;

  /// Whether to automatically make predictions when weather data changes
  final bool autoPredict;

  const AiPredictionFeature({
    super.key,
    this.weatherData,
    this.autoPredict = false,
  });

  @override
  Widget build(BuildContext context) {
    return AiPredictionProvider(
      child: AiPredictionWidget(
        weatherData: weatherData,
        autoPredict: autoPredict,
      ),
    );
  }
}

/// Widget that shows AI service status
///
/// This widget can be used to display the health status of the AI prediction
/// service. It's useful for debugging or showing users when the service is unavailable.
class AiServiceStatusWidget extends StatelessWidget {
  const AiServiceStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiPredictionBloc, AiPredictionState>(
      builder: (context, state) {
        if (state is AiServiceHealthChecked) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  state.isHealthy
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.isHealthy ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: state.isHealthy ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  state.isHealthy
                      ? 'AI Service Ready'
                      : 'AI Service Unavailable',
                  style: TextStyle(
                    color: state.isHealthy ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Button widget for manually checking AI service health
///
/// This widget provides a button that users can tap to check if the
/// AI prediction service is available and ready to make predictions.
class AiHealthCheckButton extends StatelessWidget {
  const AiHealthCheckButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiPredictionBloc, AiPredictionState>(
      builder: (context, state) {
        final isLoading = state is AiPredictionLoading;

        return ElevatedButton.icon(
          onPressed:
              isLoading
                  ? null
                  : () {
                    context.read<AiPredictionBloc>().add(
                      const CheckServiceHealth(),
                    );
                  },
          icon:
              isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.health_and_safety, size: 16),
          label: Text(isLoading ? 'Checking...' : 'Check AI Service'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.withValues(alpha: 0.2),
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
