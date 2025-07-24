import 'package:equatable/equatable.dart';

class WeatherData extends Equatable {
  final String location;
  final double temperature;

  /// Current temperature in Celsius
  final String condition;

  /// Weather condition description (e.g., "Sunny", "Cloudy")
  final String iconUrl;

  /// Weather condition icon URL
  final double windSpeed;

  /// Wind speed in km/h
  final int humidity;

  /// Humidity percentage
  final double pressure;

  /// Atmospheric pressure in mb
  final double uvIndex;
  final int cloudiness;

  /// Cloud coverage percentage
  final double feelsLike;

  /// "Feels like" temperature in Celsius
  final double visibility;

  /// Visibility in kilometers
  final DateTime lastUpdated;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
    required this.uvIndex,
    required this.cloudiness,
    required this.feelsLike,
    required this.visibility,
    required this.lastUpdated,
  });

  // We extends from Equatable to avoid dublication of object
  @override
  List<Object?> get props => [
    location,
    temperature,
    condition,
    iconUrl,
    windSpeed,
    humidity,
    pressure,
    uvIndex,
    cloudiness,
    feelsLike,
    visibility,
    lastUpdated,
  ];
}
