import '../../domain/entities/prediction_result.dart';

/// Data model for AI prediction API responses
///
/// This model handles the conversion between JSON responses from the Flask API
/// and domain entities. It follows Clean Architecture by implementing the
/// domain entity and providing JSON serialization/deserialization.
///
/// The model maps the Flask API response structure to our domain entities,
/// ensuring that the presentation layer only works with domain objects.
class PredictionResponseModel extends PredictionResult {
  /// Constructor that calls the parent PredictionResult constructor
  /// All the properties are inherited from the domain entity
  const PredictionResponseModel({
    required super.prediction,
    required super.suitableForExercise,
    required super.confidence,
    required super.message,
    required super.inputFeatures,
    required super.timestamp,
  });

  /// Creates a PredictionResponseModel from JSON response
  ///
  /// This factory constructor parses the JSON response from the Flask API
  /// and converts it into a domain entity. The expected JSON structure is:
  ///
  /// ```json
  /// {
  ///   "prediction": 1,
  ///   "suitable_for_training": true,
  ///   "confidence": "high",
  ///   "message": "Suitable for training",
  ///   "input_features": {
  ///     "outlook_rainy": 0,
  ///     "outlook_sunny": 1,
  ///     "temperature_hot": 0,
  ///     "temperature_mild": 1,
  ///     "humidity_normal": 1
  ///   }
  /// }
  /// ```
  ///
  /// Parameters:
  /// - [json]: The JSON response from the Flask API
  ///
  /// Returns: A PredictionResponseModel instance with parsed data
  ///
  /// Throws: FormatException if JSON structure is invalid
  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse the input features from the nested object
      final inputFeaturesJson = json['input_features'] as Map<String, dynamic>;
      final inputFeatures = WeatherFeaturesModel.fromJson(inputFeaturesJson);

      return PredictionResponseModel(
        // Parse the raw prediction value (0 or 1)
        prediction: json['prediction'] as int,

        // Parse the boolean suitability flag
        suitableForExercise: json['suitable_for_training'] as bool,

        // Parse the confidence level string
        confidence: json['confidence'] as String? ?? 'unknown',

        // Parse the human-readable message
        message: json['message'] as String? ?? 'No message provided',

        // Use the parsed input features
        inputFeatures: inputFeatures,

        // Set timestamp to current time (API doesn't provide this)
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Provide helpful error message if JSON parsing fails
      throw FormatException(
        'Failed to parse prediction response: ${e.toString()}',
      );
    }
  }

  /// Converts the model to JSON format
  ///
  /// This method is useful for caching, logging, or debugging purposes.
  /// It converts the domain entity back to the JSON format expected by the API.
  ///
  /// Returns: A Map representing the JSON structure
  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'suitable_for_training': suitableForExercise,
      'confidence': confidence,
      'message': message,
      'input_features': (inputFeatures as WeatherFeaturesModel).toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Data model for weather features used in API requests and responses
///
/// This model handles the conversion between the domain WeatherFeatures entity
/// and the JSON format expected by the Flask API. It provides methods for
/// both serialization (to send requests) and deserialization (to parse responses).
class WeatherFeaturesModel extends WeatherFeatures {
  /// Constructor that calls the parent WeatherFeatures constructor
  /// All properties are inherited from the domain entity
  const WeatherFeaturesModel({
    required super.outlookRainy,
    required super.outlookSunny,
    required super.temperatureHot,
    required super.temperatureMild,
    required super.humidityNormal,
  });

  /// Creates WeatherFeaturesModel from JSON
  ///
  /// This factory constructor parses JSON from API responses that contain
  /// the input features that were used for prediction. The expected format is:
  ///
  /// ```json
  /// {
  ///   "outlook_rainy": 0,
  ///   "outlook_sunny": 1,
  ///   "temperature_hot": 0,
  ///   "temperature_mild": 1,
  ///   "humidity_normal": 1
  /// }
  /// ```
  ///
  /// Parameters:
  /// - [json]: JSON object containing weather features
  ///
  /// Returns: WeatherFeaturesModel instance with parsed data
  ///
  /// Throws: FormatException if JSON structure is invalid
  factory WeatherFeaturesModel.fromJson(Map<String, dynamic> json) {
    try {
      return WeatherFeaturesModel(
        // Convert integer values (0/1) back to boolean
        outlookRainy: (json['outlook_rainy'] as int) == 1,
        outlookSunny: (json['outlook_sunny'] as int) == 1,
        temperatureHot: (json['temperature_hot'] as int) == 1,
        temperatureMild: (json['temperature_mild'] as int) == 1,
        humidityNormal: (json['humidity_normal'] as int) == 1,
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse weather features: ${e.toString()}',
      );
    }
  }

  /// Creates WeatherFeaturesModel from domain entity
  ///
  /// This factory constructor allows easy conversion from the domain
  /// WeatherFeatures entity to the data model for API communication.
  ///
  /// Parameters:
  /// - [features]: Domain WeatherFeatures entity
  ///
  /// Returns: WeatherFeaturesModel instance
  factory WeatherFeaturesModel.fromDomain(WeatherFeatures features) {
    return WeatherFeaturesModel(
      outlookRainy: features.outlookRainy,
      outlookSunny: features.outlookSunny,
      temperatureHot: features.temperatureHot,
      temperatureMild: features.temperatureMild,
      humidityNormal: features.humidityNormal,
    );
  }

  /// Converts the model to JSON format for API requests
  ///
  /// This method creates the JSON structure expected by the Flask API
  /// for making prediction requests. The boolean values are converted
  /// to integers (0/1) as expected by the machine learning model.
  ///
  /// Returns: Map representing the JSON request body
  Map<String, dynamic> toJson() {
    return {
      'outlook_rainy': outlookRainy ? 1 : 0,
      'outlook_sunny': outlookSunny ? 1 : 0,
      'temperature_hot': temperatureHot ? 1 : 0,
      'temperature_mild': temperatureMild ? 1 : 0,
      'humidity_normal': humidityNormal ? 1 : 0,
    };
  }

  /// Converts to the features array format expected by the API
  ///
  /// This method creates the array format that the Flask API expects
  /// in the request body: {"features": [0, 1, 0, 1, 1]}
  ///
  /// Returns: Map with 'features' key containing binary array
  Map<String, dynamic> toApiRequest() {
    return {'features': toBinaryList()};
  }
}
