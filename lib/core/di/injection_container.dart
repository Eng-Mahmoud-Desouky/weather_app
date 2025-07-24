import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/home_page/data/datasources/weather_remote_data_source.dart';
import '../../features/home_page/data/repositories/weather_repository_impl.dart';
import '../../features/home_page/domain/repositories/weather_repository.dart';
import '../../features/home_page/domain/usecases/get_current_weather.dart';
import '../../features/home_page/domain/usecases/get_weather_forecast.dart';
import '../../features/home_page/presentation/bloc/home_page_bloc.dart';
import '../constants/api_constants.dart';

/// Service locator instance for dependency injection
/// This follows the Service Locator pattern for managing dependencies
final sl = GetIt.instance;

/// Initializes all dependencies for the application
/// This should be called once at app startup
Future<void> init() async {
  //! Features - Home Page
  // BLoC
  sl.registerFactory(
    () => HomePageBloc(getCurrentWeather: sl(), getWeatherForecast: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentWeather(sl()));
  sl.registerLazySingleton(() => GetWeatherForecast(sl()));

  // Repository
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(dio: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => _createDio());
}

/// Creates and configures a Dio instance for HTTP requests
/// This centralizes HTTP client configuration
Dio _createDio() {
  final dio = Dio();

  // Configure base options
  dio.options = BaseOptions(
    connectTimeout: Duration(milliseconds: ApiConstants.timeoutDuration),
    receiveTimeout: Duration(milliseconds: ApiConstants.timeoutDuration),
    sendTimeout: Duration(milliseconds: ApiConstants.timeoutDuration),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  // Add interceptors for logging in debug mode
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) {
          // Use debugPrint for better logging in debug mode
          // ignore: avoid_print
          print('[DIO] $object');
        },
      ),
    );
  }

  return dio;
}
