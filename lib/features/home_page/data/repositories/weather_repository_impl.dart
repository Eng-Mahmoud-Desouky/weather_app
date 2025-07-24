import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/weather_data_entitie.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';

/// Implementation of WeatherRepository
/// This class handles the conversion between data layer exceptions and domain failures
/// Following Clean Architecture principles by implementing the domain repository interface
class WeatherRepositoryImpl implements WeatherRepository {
  /// Remote data source dependency
  final WeatherRemoteDataSource remoteDataSource;

  const WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WeatherData>> getCurrentWeather(
    String location,
  ) async {
    try {
      // Fetch data from remote source
      final weatherModel = await remoteDataSource.getCurrentWeather(location);

      // Return success with the weather data
      return Right(weatherModel);
    } on DioException catch (e) {
      // Convert DioException to appropriate Failure
      return Left(_handleDioException(e));
    } on FormatException catch (e) {
      // Handle JSON parsing errors
      return Left(
        DataParsingFailure('Failed to parse weather data: ${e.message}'),
      );
    } catch (e) {
      // Handle any other unexpected errors
      return Left(UnexpectedFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WeatherData>>> getWeatherForecast(
    String location, {
    int days = 3,
  }) async {
    try {
      // Fetch data from remote source
      final weatherModels = await remoteDataSource.getWeatherForecast(
        location,
        days,
      );

      // Convert models to entities and return success
      final weatherDataList = weatherModels.cast<WeatherData>();
      return Right(weatherDataList);
    } on DioException catch (e) {
      // Convert DioException to appropriate Failure
      return Left(_handleDioException(e));
    } on FormatException catch (e) {
      // Handle JSON parsing errors
      return Left(
        DataParsingFailure('Failed to parse forecast data: ${e.message}'),
      );
    } catch (e) {
      // Handle any other unexpected errors
      return Left(UnexpectedFailure('An unexpected error occurred: $e'));
    }
  }

  /// Converts DioException to appropriate domain Failure
  /// This method centralizes error handling logic
  Failure _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your network settings.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return const LocationNotFoundFailure(
              'Invalid location. Please check the location name.',
            );
          case 401:
          case 403:
            return const ApiKeyFailure('Invalid API key or access denied.');
          case 404:
            return const LocationNotFoundFailure(
              'Location not found. Please try a different location.',
            );
          case 429:
            return const ApiKeyFailure(
              'API quota exceeded. Please try again later.',
            );
          case 500:
          case 502:
          case 503:
            return const ServerFailure('Server error. Please try again later.');
          default:
            return ServerFailure('Server error: ${statusCode ?? 'Unknown'}');
        }

      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled.');

      case DioExceptionType.unknown:
      default:
        return UnexpectedFailure(
          'Network error: ${e.message ?? 'Unknown error'}',
        );
    }
  }
}
