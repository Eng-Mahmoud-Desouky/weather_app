import '../entities/prediction_result.dart';
import '../../../home_page/domain/entities/weather_data_entitie.dart';

/// Utility class for converting weather data to AI model features
///
/// This class contains the business logic for converting weather data from the
/// home_page feature into the 5 binary features required by the AI model:
/// 1. outlook is rainy (0/1)
/// 2. outlook is sunny (0/1)
/// 3. temperature is hot (0/1)
/// 4. temperature is mild (0/1)
/// 5. humidity is normal (0/1)
///
/// The conversion rules are based on weather thresholds and conditions
/// that determine training suitability. These thresholds can be adjusted
/// based on domain expertise and user feedback.
class WeatherFeatureConverter {
  // Temperature thresholds (in Celsius)
  /// Temperature above this value is considered "hot"
  static const double hotTemperatureThreshold = 30.0;

  /// Temperature between this and hot threshold is considered "mild"
  static const double mildTemperatureMinThreshold = 15.0;

  // Humidity thresholds (percentage)
  /// Humidity between these values is considered "normal"
  static const double normalHumidityMinThreshold = 40.0;
  static const double normalHumidityMaxThreshold = 70.0;

  // Weather condition keywords for classification
  /// Keywords that indicate rainy weather conditions
  static const List<String> rainyConditions = [
    'rain',
    'rainy',
    'drizzle',
    'shower',
    'thunderstorm',
    'storm',
  ];

  /// Keywords that indicate sunny weather conditions
  static const List<String> sunnyConditions = [
    'sunny',
    'clear',
    'bright',
    'sunshine',
  ];

  /// Converts WeatherData to WeatherFeatures for AI prediction
  ///
  /// This method analyzes the weather data and determines which of the
  /// 5 binary features should be set to true (1) or false (0) based on
  /// the current weather conditions.
  ///
  /// Parameters:
  /// - [weatherData]: The weather data from the home_page feature
  ///
  /// Returns: WeatherFeatures with binary values for AI model input
  ///
  /// Example:
  /// ```dart
  /// final weatherData = WeatherData(
  ///   temperature: 25.0,
  ///   condition: 'Partly cloudy',
  ///   humidity: 60,
  ///   // ... other properties
  /// );
  ///
  /// final features = WeatherFeatureConverter.convertWeatherData(weatherData);
  /// // Result: outlookRainy=false, outlookSunny=false, temperatureHot=false,
  /// //         temperatureMild=true, humidityNormal=true
  /// ```
  static WeatherFeatures convertWeatherData(WeatherData weatherData) {
    // Analyze weather outlook (rainy vs sunny)
    final outlookRainy = _isRainyCondition(weatherData.condition);
    final outlookSunny = _isSunnyCondition(weatherData.condition);

    // Analyze temperature (hot vs mild)
    final temperatureHot = _isHotTemperature(weatherData.temperature);
    final temperatureMild = _isMildTemperature(weatherData.temperature);

    // Analyze humidity (normal range)
    final humidityNormal = _isNormalHumidity(weatherData.humidity);

    return WeatherFeatures(
      outlookRainy: outlookRainy,
      outlookSunny: outlookSunny,
      temperatureHot: temperatureHot,
      temperatureMild: temperatureMild,
      humidityNormal: humidityNormal,
    );
  }

  /// Determines if the weather condition indicates rainy weather
  ///
  /// Checks if the weather condition string contains keywords that
  /// indicate rainy or stormy weather conditions.
  ///
  /// Parameters:
  /// - [condition]: Weather condition string (e.g., "Light rain")
  ///
  /// Returns: true if condition indicates rainy weather, false otherwise
  static bool _isRainyCondition(String condition) {
    final lowerCondition = condition.toLowerCase();
    return rainyConditions.any((keyword) => lowerCondition.contains(keyword));
  }

  /// Determines if the weather condition indicates sunny weather
  ///
  /// Checks if the weather condition string contains keywords that
  /// indicate sunny or clear weather conditions.
  ///
  /// Parameters:
  /// - [condition]: Weather condition string (e.g., "Sunny")
  ///
  /// Returns: true if condition indicates sunny weather, false otherwise
  static bool _isSunnyCondition(String condition) {
    final lowerCondition = condition.toLowerCase();
    return sunnyConditions.any((keyword) => lowerCondition.contains(keyword));
  }

  /// Determines if the temperature is considered "hot"
  ///
  /// Checks if the temperature is above the hot temperature threshold.
  /// Hot weather might not be ideal for intensive training activities.
  ///
  /// Parameters:
  /// - [temperature]: Temperature in Celsius
  ///
  /// Returns: true if temperature is hot, false otherwise
  static bool _isHotTemperature(double temperature) {
    return temperature > hotTemperatureThreshold;
  }

  /// Determines if the temperature is considered "mild"
  ///
  /// Checks if the temperature is in the mild range - not too hot and not too cold.
  /// Mild weather is generally considered ideal for training activities.
  ///
  /// Parameters:
  /// - [temperature]: Temperature in Celsius
  ///
  /// Returns: true if temperature is mild, false otherwise
  static bool _isMildTemperature(double temperature) {
    return temperature >= mildTemperatureMinThreshold &&
        temperature <= hotTemperatureThreshold;
  }

  /// Determines if the humidity is in the normal range
  ///
  /// Checks if the humidity is within the normal range that's comfortable
  /// for training activities. Very low or very high humidity can be uncomfortable.
  ///
  /// Parameters:
  /// - [humidity]: Humidity percentage (0-100)
  ///
  /// Returns: true if humidity is normal, false otherwise
  static bool _isNormalHumidity(int humidity) {
    return humidity >= normalHumidityMinThreshold &&
        humidity <= normalHumidityMaxThreshold;
  }

  /// Gets a human-readable explanation of the feature conversion
  ///
  /// This method provides detailed information about how the weather data
  /// was converted to features, which can be useful for debugging or
  /// showing users why certain predictions were made.
  ///
  /// Parameters:
  /// - [weatherData]: The original weather data
  /// - [features]: The converted weather features
  ///
  /// Returns: A detailed explanation string
  static String getConversionExplanation(
    WeatherData weatherData,
    WeatherFeatures features,
  ) {
    final explanations = <String>[];

    // Explain outlook classification
    if (features.outlookRainy) {
      explanations.add('Weather is rainy (${weatherData.condition})');
    } else if (features.outlookSunny) {
      explanations.add('Weather is sunny (${weatherData.condition})');
    } else {
      explanations.add(
        'Weather is neither rainy nor sunny (${weatherData.condition})',
      );
    }

    // Explain temperature classification
    if (features.temperatureHot) {
      explanations.add(
        'Temperature is hot (${weatherData.temperature}°C > $hotTemperatureThreshold°C)',
      );
    } else if (features.temperatureMild) {
      explanations.add(
        'Temperature is mild ($mildTemperatureMinThreshold°C ≤ ${weatherData.temperature}°C ≤ $hotTemperatureThreshold°C)',
      );
    } else {
      explanations.add(
        'Temperature is cold (${weatherData.temperature}°C < $mildTemperatureMinThreshold°C)',
      );
    }

    // Explain humidity classification
    if (features.humidityNormal) {
      explanations.add(
        'Humidity is normal ($normalHumidityMinThreshold% ≤ ${weatherData.humidity}% ≤ $normalHumidityMaxThreshold%)',
      );
    } else {
      explanations.add(
        'Humidity is not normal (${weatherData.humidity}% outside $normalHumidityMinThreshold%-$normalHumidityMaxThreshold% range)',
      );
    }

    return explanations.join('\n');
  }
}
