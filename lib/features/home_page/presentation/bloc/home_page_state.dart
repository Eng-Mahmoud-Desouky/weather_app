part of 'home_page_bloc.dart';

/// Base class for all home page states
/// States represent the current condition of the home page UI
sealed class HomePageState extends Equatable {
  const HomePageState();

  @override
  List<Object> get props => [];
}

/// Initial state when the home page is first loaded
final class HomePageInitial extends HomePageState {}

/// State when weather data is being fetched
final class WeatherLoading extends HomePageState {}

/// State when current weather data has been successfully loaded
final class CurrentWeatherLoaded extends HomePageState {
  /// The current weather data
  final WeatherData weatherData;

  const CurrentWeatherLoaded(this.weatherData);

  @override
  List<Object> get props => [weatherData];
}

/// State when weather forecast data has been successfully loaded
final class WeatherForecastLoaded extends HomePageState {
  /// The current weather data
  final WeatherData currentWeather;

  /// List of forecast weather data
  final List<WeatherData> forecastData;

  const WeatherForecastLoaded({
    required this.currentWeather,
    required this.forecastData,
  });

  @override
  List<Object> get props => [currentWeather, forecastData];
}

/// State when an error occurs while fetching weather data
final class WeatherError extends HomePageState {
  /// Error message to display to the user
  final String message;

  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}
