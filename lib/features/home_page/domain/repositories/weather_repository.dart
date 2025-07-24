import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_data_entitie.dart';

/// Abstract repository interface for weather data operations
/// This defines the contract that the data layer must implement
/// Following the Dependency Inversion Principle of Clean Architecture
abstract class WeatherRepository {
  /// Returns [Right(WeatherData)] on success
  /// Returns [Left(Failure)] on error (network, server, parsing, etc.)
  Future<Either<Failure, WeatherData>> getCurrentWeather(String location);

  // Fetches weather forecast for a given location
  Future<Either<Failure, List<WeatherData>>> getWeatherForecast(
    String location, {
    int days = 3,
  });
}
