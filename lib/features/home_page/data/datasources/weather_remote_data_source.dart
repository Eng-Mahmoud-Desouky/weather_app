import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/weather_model.dart';

/// Abstract interface for weather remote data source
/// This defines the contract for fetching weather data from external APIs
abstract class WeatherRemoteDataSource {
  /// Fetches current weather data from the API
  Future<WeatherModel> getCurrentWeather(String location);

  /// Fetches weather forecast data from the API
  Future<List<WeatherModel>> getWeatherForecast(String location, int days);
}

/// Implementation of WeatherRemoteDataSource using Dio HTTP client
/// This handles all the HTTP communication with the weather API
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  /// Dio HTTP client for making API requests
  final Dio dio;

  WeatherRemoteDataSourceImpl({required this.dio});

  @override
  Future<WeatherModel> getCurrentWeather(String location) async {
    try {
      // Construct the API request URL with parameters
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.currentWeatherEndpoint}',
        queryParameters: {
          'key': ApiConstants.apiKey,
          'q': location,
          'aqi': 'no', // We don't need air quality data for now
        },

        // TODO : Understand this option
        options: Options(
          sendTimeout: Duration(milliseconds: ApiConstants.timeoutDuration),
          receiveTimeout: Duration(milliseconds: ApiConstants.timeoutDuration),
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch weather data: ${response.statusCode}',
        );
      }
    } on DioException {
      // Re-throw DioException to be handled by repository
      rethrow;
    } catch (e) {
      // Wrap other exceptions in DioException for consistent error handling
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Unexpected error: $e',
      );
    }
  }

  @override
  Future<List<WeatherModel>> getWeatherForecast(
    String location,
    int days,
  ) async {
    try {
      // Construct the API request URL with parameters
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.forecastEndpoint}',
        queryParameters: {
          'key': ApiConstants.apiKey,
          'q': location,
          'days': days,
          'aqi': 'no', // We don't need air quality data for now
          'alerts': 'no', // We don't need weather alerts for now
        },
        options: Options(
          sendTimeout: Duration(milliseconds: ApiConstants.timeoutDuration),
          receiveTimeout: Duration(milliseconds: ApiConstants.timeoutDuration),
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final forecast = data['forecast'] as Map<String, dynamic>;
        final forecastDays = forecast['forecastday'] as List<dynamic>;

        // Convert each forecast day to WeatherModel
        return forecastDays.map((dayData) {
          // Transform forecast day data to match current weather structure
          final day = dayData as Map<String, dynamic>;
          final dayInfo = day['day'] as Map<String, dynamic>;
          final condition = dayInfo['condition'] as Map<String, dynamic>;

          // Create a structure similar to current weather for consistency
          // For forecast, we'll use max temp as main temp and min temp as feels like
          final transformedData = {
            'location': data['location'],
            'current': {
              'temp_c':
                  dayInfo['maxtemp_c'], // Use max temperature as main temp
              'condition': condition,
              'wind_kph': dayInfo['maxwind_kph'],
              'humidity': dayInfo['avghumidity'],
              'pressure_mb':
                  1013.0, // Default value as forecast doesn't include pressure
              'uv': dayInfo['uv'] ?? 0.0,
              'cloud':
                  50, // Default value as forecast doesn't include cloud coverage
              'feelslike_c':
                  dayInfo['mintemp_c'], // Use min temp as feels like for forecast
              'vis_km': dayInfo['avgvis_km'] ?? 10.0,
              'last_updated': '${day['date']} 12:00', // Add time for parsing
            },
          };

          return WeatherModel.fromJson(transformedData);
        }).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch forecast data: ${response.statusCode}',
        );
      }
    } on DioException {
      // Re-throw DioException to be handled by repository
      rethrow;
    } catch (e) {
      // Wrap other exceptions in DioException for consistent error handling
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Unexpected error: $e',
      );
    }
  }
}
