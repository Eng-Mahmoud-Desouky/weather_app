import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_data_entitie.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting current weather data
/// This encapsulates the business logic for fetching current weather
/// and follows the Single Responsibility Principle
class GetCurrentWeather {
  /// Repository dependency injected through constructor
  final WeatherRepository repository;

  const GetCurrentWeather(this.repository);

  // Executes the use case to get current weather for a location
  Future<Either<Failure, WeatherData>> call(String location) async {
    // Validate input
    if (location.trim().isEmpty) {
      return const Left(DataParsingFailure('Location cannot be empty'));
    }
    // Delegate to repository
    return await repository.getCurrentWeather(location.trim());
  }
}
