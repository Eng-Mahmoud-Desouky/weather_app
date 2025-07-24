import '../../domain/entities/weather_data_entitie.dart';

/// Data model for weather information from the API
/// This model handles the conversion between API JSON response and domain entity
/// Following the Clean Architecture principle of data layer independence
class WeatherModel extends WeatherData {
  const WeatherModel({
    required super.location,
    required super.temperature,
    required super.condition,
    required super.iconUrl,
    required super.windSpeed,
    required super.humidity,
    required super.pressure,
    required super.uvIndex,
    required super.cloudiness,
    required super.feelsLike,
    required super.visibility,
    required super.lastUpdated,
  });

  /// Creates a WeatherModel from JSON response from the weather API
  ///
  /// Expected JSON structure from weatherapi.com:
  /// {
  ///   "location": {"name": "London", "country": "UK"},
  ///   "current": {
  ///     "temp_c": 20.0,
  ///     "condition": {"text": "Sunny", "icon": "//cdn.weatherapi.com/..."},
  ///     "wind_kph": 10.0,
  ///     "humidity": 65,
  ///     "pressure_mb": 1013.0,
  ///     "uv": 5.0,
  ///     "cloud": 25,
  ///     "feelslike_c": 22.0,
  ///     "vis_km": 10.0,
  ///     "last_updated": "2024-01-15 12:00"
  ///   }
  /// }
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    try {
      final location = json['location'] as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>;
      final condition = current['condition'] as Map<String, dynamic>;

      return WeatherModel(
        location: '${location['name']}, ${location['country']}',
        temperature: (current['temp_c'] as num).toDouble(),
        condition: condition['text'] as String,
        iconUrl:
            'https:${condition['icon']}', // API returns protocol-relative URL
        windSpeed: (current['wind_kph'] as num).toDouble(),
        humidity: current['humidity'] as int,
        pressure: (current['pressure_mb'] as num).toDouble(),
        uvIndex: (current['uv'] as num).toDouble(),
        cloudiness: current['cloud'] as int,
        feelsLike: (current['feelslike_c'] as num).toDouble(),
        visibility: (current['vis_km'] as num).toDouble(),
        lastUpdated: DateTime.parse(current['last_updated'] as String),
      );
    } catch (e) {
      throw FormatException('Failed to parse weather data: $e');
    }
  }
}
