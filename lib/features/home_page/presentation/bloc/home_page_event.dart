part of 'home_page_bloc.dart';

/// Base class for all home page events
/// Events represent user actions or system triggers that can change the state
sealed class HomePageEvent extends Equatable {
  const HomePageEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch current weather data for a specific location
final class FetchCurrentWeather extends HomePageEvent {
  /// The location to fetch weather for
  final String location;

  const FetchCurrentWeather(this.location);

  @override
  List<Object> get props => [location];
}

/// Event to fetch weather forecast for a specific location
final class FetchWeatherForecast extends HomePageEvent {
  /// The location to fetch forecast for
  final String location;

  /// Number of days to forecast (default: 7)
  final int days;

  const FetchWeatherForecast(this.location, {this.days = 7});

  @override
  List<Object> get props => [location, days];
}

/// Event to refresh weather data (re-fetch current weather)
final class RefreshWeather extends HomePageEvent {
  /// The location to refresh weather for
  final String location;

  const RefreshWeather(this.location);

  @override
  List<Object> get props => [location];
}
