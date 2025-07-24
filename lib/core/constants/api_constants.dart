/// API configuration constants for the weather application
/// Contains base URLs, API keys, and endpoint configurations
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  /// Base URL for the Weather API
  static const String baseUrl = 'https://api.weatherapi.com/v1';

  /// API key for accessing the Weather API
  /// Note: In production, this should be stored securely (e.g., environment variables)
  static const String apiKey = '9b829b44e1da4c89ae874802251607';

  /// Endpoint for current weather data
  static const String currentWeatherEndpoint = '/current.json';

  /// Endpoint for weather forecast data
  static const String forecastEndpoint = '/forecast.json';

  /// Default timeout duration for HTTP requests (in milliseconds)
  static const int timeoutDuration = 30000;

  /// Default location for weather data when location is not provided
  static const String defaultLocation = 'Egypt';
}
