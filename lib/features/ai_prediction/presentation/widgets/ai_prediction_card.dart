import 'package:flutter/material.dart';
import '../../domain/entities/prediction_result.dart';
import '../../../home_page/domain/entities/weather_data_entitie.dart';

/// Widget that displays AI exercise suitability prediction results
///
/// This widget shows the AI model's prediction about whether current weather
/// conditions are suitable for outdoor exercise. It displays:
/// - The prediction result (suitable/not suitable)
/// - Weather conditions that were analyzed
/// - Visual indicators and icons
/// - Confidence level and additional details
///
/// The widget is designed to integrate seamlessly with the existing weather app UI,
/// following the same design patterns and styling as other weather cards.
class AiPredictionCard extends StatelessWidget {
  /// The prediction result from the AI model
  /// Contains all the information about training suitability
  final PredictionResult? predictionResult;

  /// The weather data that was used to make the prediction
  /// Used to show context about what conditions were analyzed
  final WeatherData? weatherData;

  /// Whether the AI prediction is currently loading
  /// Shows loading indicator when true
  final bool isLoading;

  /// Error message to display if prediction failed
  /// Shows error state when not null
  final String? errorMessage;

  /// Callback function when the user taps the refresh button
  /// Allows the parent widget to trigger a new prediction
  final VoidCallback? onRefresh;

  const AiPredictionCard({
    super.key,
    this.predictionResult,
    this.weatherData,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Use gradient background for AI prediction card to distinguish it
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with title and refresh button
          _buildHeader(),

          const SizedBox(height: 16),

          // Main content based on current state
          if (isLoading)
            _buildLoadingState()
          else if (errorMessage != null)
            _buildErrorState()
          else if (predictionResult != null)
            _buildPredictionResult()
          else
            _buildInitialState(),
        ],
      ),
    );
  }

  /// Builds the header section with title and refresh button
  Widget _buildHeader() {
    return Row(
      children: [
        // AI icon and title
        const Icon(Icons.psychology, color: Colors.white70, size: 24),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'AI Training Prediction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Refresh button (only show if callback is provided)
        if (onRefresh != null)
          IconButton(
            onPressed: isLoading ? null : onRefresh,
            icon: Icon(
              Icons.refresh,
              color: isLoading ? Colors.white30 : Colors.white70,
              size: 20,
            ),
            tooltip: 'Refresh prediction',
          ),
      ],
    );
  }

  /// Builds the loading state UI
  Widget _buildLoadingState() {
    return const Column(
      children: [
        SizedBox(height: 20),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
        ),
        SizedBox(height: 16),
        Text(
          'Analyzing weather conditions...',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  /// Builds the error state UI
  Widget _buildErrorState() {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Prediction Failed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage ?? 'Unknown error occurred',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (onRefresh != null)
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  /// Builds the initial state UI (before any prediction is made)
  Widget _buildInitialState() {
    return Column(
      children: [
        const Icon(Icons.psychology_outlined, color: Colors.white70, size: 48),
        const SizedBox(height: 12),
        const Text(
          'AI Prediction Ready',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap refresh to analyze current weather conditions for training suitability',
          style: TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (onRefresh != null)
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.psychology, size: 16),
            label: const Text('Analyze Weather'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  /// Builds the prediction result UI
  Widget _buildPredictionResult() {
    final result = predictionResult!;
    final isSuitable = result.suitableForExercise;

    return Column(
      children: [
        // Main prediction result
        Row(
          children: [
            // Prediction icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSuitable
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSuitable ? Icons.check_circle : Icons.warning,
                color: isSuitable ? Colors.green : Colors.orange,
                size: 32,
              ),
            ),

            const SizedBox(width: 16),

            // Prediction text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${result.confidence}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Weather conditions analyzed
        _buildAnalyzedConditions(result.inputFeatures),

        const SizedBox(height: 12),

        // Timestamp
        Text(
          'Analyzed at ${_formatTime(result.timestamp)}',
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  /// Builds the analyzed weather conditions section
  Widget _buildAnalyzedConditions(WeatherFeatures features) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyzed Conditions:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            features.getSummary(),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Formats timestamp for display
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
