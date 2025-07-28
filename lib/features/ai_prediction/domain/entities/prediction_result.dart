import 'package:equatable/equatable.dart';

/// Entity representing the result of an AI exercise suitability prediction
///
/// This entity encapsulates all the information returned by the AI model
/// when predicting whether current weather conditions are suitable for outdoor exercise.
///
/// Following Clean Architecture principles, this entity is independent of
/// any external frameworks and contains only business logic data.
class PredictionResult extends Equatable {
  /// The raw prediction value from the AI model (0 or 1)
  /// 0 = Not suitable for exercise
  /// 1 = Suitable for exercise
  final int prediction;

  /// Human-readable boolean indicating exercise suitability
  /// true = Suitable for exercise
  /// false = Not suitable for exercise
  final bool suitableForExercise;

  /// Confidence level of the prediction (e.g., 'high', 'medium', 'low')
  /// This can be enhanced based on model capabilities
  final String confidence;

  /// Human-readable message explaining the prediction result
  /// Examples: "Suitable for exercise", "Not suitable for exercise"
  final String message;

  /// The input features that were used to make this prediction
  /// This helps with transparency and debugging
  final WeatherFeatures inputFeatures;

  /// Timestamp when this prediction was made
  /// Useful for caching and tracking prediction history
  final DateTime timestamp;

  const PredictionResult({
    required this.prediction,
    required this.suitableForExercise,
    required this.confidence,
    required this.message,
    required this.inputFeatures,
    required this.timestamp,
  });

  /// Creates a PredictionResult representing a successful exercise prediction
  factory PredictionResult.suitable({
    required WeatherFeatures inputFeatures,
    String confidence = 'high',
  }) {
    return PredictionResult(
      prediction: 1,
      suitableForExercise: true,
      confidence: confidence,
      message: 'Suitable for exercise',
      inputFeatures: inputFeatures,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a PredictionResult representing an unsuitable exercise prediction
  factory PredictionResult.notSuitable({
    required WeatherFeatures inputFeatures,
    String confidence = 'high',
  }) {
    return PredictionResult(
      prediction: 0,
      suitableForExercise: false,
      confidence: confidence,
      message: 'Not suitable for exercise',
      inputFeatures: inputFeatures,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    prediction,
    suitableForExercise,
    confidence,
    message,
    inputFeatures,
    timestamp,
  ];
}

/// Entity representing the weather features used as input for AI prediction
///
/// This entity converts weather data into the 5 binary features required
/// by the machine learning model. Each feature is a boolean value that
/// gets converted to 0 or 1 when sent to the AI model.
class WeatherFeatures extends Equatable {
  /// Whether the weather outlook is rainy (true = 1, false = 0)
  final bool outlookRainy;

  /// Whether the weather outlook is sunny (true = 1, false = 0)
  final bool outlookSunny;

  /// Whether the temperature is hot (true = 1, false = 0)
  final bool temperatureHot;

  /// Whether the temperature is mild (true = 1, false = 0)
  final bool temperatureMild;

  /// Whether the humidity is normal (true = 1, false = 0)
  final bool humidityNormal;

  const WeatherFeatures({
    required this.outlookRainy,
    required this.outlookSunny,
    required this.temperatureHot,
    required this.temperatureMild,
    required this.humidityNormal,
  });

  /// Converts the weather features to a list of binary values (0/1)
  /// This is the format expected by the AI model API
  ///
  /// Returns: [outlookRainy, outlookSunny, temperatureHot, temperatureMild, humidityNormal]
  /// where each boolean is converted to 1 (true) or 0 (false)
  List<int> toBinaryList() {
    return [
      outlookRainy ? 1 : 0,
      outlookSunny ? 1 : 0,
      temperatureHot ? 1 : 0,
      temperatureMild ? 1 : 0,
      humidityNormal ? 1 : 0,
    ];
  }

  /// Creates a human-readable summary of the weather features
  /// Useful for displaying to users what conditions were analyzed
  String getSummary() {
    final conditions = <String>[];

    if (outlookRainy) conditions.add('Rainy');
    if (outlookSunny) conditions.add('Sunny');
    if (temperatureHot) conditions.add('Hot');
    if (temperatureMild) conditions.add('Mild');
    if (humidityNormal) conditions.add('Normal Humidity');

    return conditions.isEmpty
        ? 'No specific conditions'
        : conditions.join(', ');
  }

  @override
  List<Object?> get props => [
    outlookRainy,
    outlookSunny,
    temperatureHot,
    temperatureMild,
    humidityNormal,
  ];
}
