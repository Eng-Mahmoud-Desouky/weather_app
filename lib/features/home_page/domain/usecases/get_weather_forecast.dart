import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_data_entitie.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting weather forecast data
/// This encapsulates the business logic for fetching weather forecast
/// and follows the Single Responsibility Principle
class GetWeatherForecast {
  /// Repository dependency injected through constructor
  final WeatherRepository repository;
  
  const GetWeatherForecast(this.repository);
  
  /// Executes the use case to get weather forecast for a location
  /// 
  /// [location] - The city or location name to get forecast for
  /// [days] - Number of days to forecast (default: 7, max: 10)
  /// 
  /// Returns [Right(List<WeatherData>)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, List<WeatherData>>> call(
    String location, {
    int days = 7,
  }) async {
    // Validate input
    if (location.trim().isEmpty) {
      return const Left(DataParsingFailure('Location cannot be empty'));
    }
    
    if (days < 1 || days > 10) {
      return const Left(DataParsingFailure('Days must be between 1 and 10'));
    }
    
    // Delegate to repository
    return await repository.getWeatherForecast(location.trim(), days: days);
  }
}
