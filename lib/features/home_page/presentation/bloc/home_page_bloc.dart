import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_data_entitie.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_weather_forecast.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

/// BLoC for managing home page state and weather data
/// This handles all the business logic for the home page UI
/// Following the BLoC pattern for clean separation of concerns
class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  /// Use case for fetching current weather
  final GetCurrentWeather getCurrentWeather;

  /// Use case for fetching weather forecast
  final GetWeatherForecast getWeatherForecast;

  HomePageBloc({
    required this.getCurrentWeather,
    required this.getWeatherForecast,
  }) : super(HomePageInitial()) {
    // Register event handlers
    on<FetchCurrentWeather>(_onFetchCurrentWeather);
    on<FetchWeatherForecast>(_onFetchWeatherForecast);
    on<RefreshWeather>(_onRefreshWeather);
  }

  /// Handles the FetchCurrentWeather event
  Future<void> _onFetchCurrentWeather(
    FetchCurrentWeather event,
    Emitter<HomePageState> emit,
  ) async {
    // Emit loading state
    emit(WeatherLoading());

    // Execute the use case
    final result = await getCurrentWeather(event.location);

    // Handle the result
    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (weatherData) => emit(CurrentWeatherLoaded(weatherData)),
    );
  }

  /// Handles the FetchWeatherForecast event
  Future<void> _onFetchWeatherForecast(
    FetchWeatherForecast event,
    Emitter<HomePageState> emit,
  ) async {
    // Emit loading state
    emit(WeatherLoading());

    // First, get current weather
    final currentResult = await getCurrentWeather(event.location);

    // If current weather fails, emit error
    if (currentResult.isLeft()) {
      currentResult.fold(
        (failure) => emit(WeatherError(failure.message)),
        (_) => null,
      );
      return;
    }

    // Get forecast data
    final forecastResult = await getWeatherForecast(
      event.location,
      days: event.days,
    );

    // Handle both results
    currentResult.fold((failure) => emit(WeatherError(failure.message)), (
      currentWeather,
    ) {
      forecastResult.fold(
        (failure) => emit(WeatherError(failure.message)),
        (forecastData) => emit(
          WeatherForecastLoaded(
            currentWeather: currentWeather,
            forecastData: forecastData,
          ),
        ),
      );
    });
  }

  /// Handles the RefreshWeather event
  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<HomePageState> emit,
  ) async {
    // For refresh, we don't show loading state to avoid UI flicker
    // Just fetch new data and update the state
    final result = await getCurrentWeather(event.location);

    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (weatherData) => emit(CurrentWeatherLoaded(weatherData)),
    );
  }
}
