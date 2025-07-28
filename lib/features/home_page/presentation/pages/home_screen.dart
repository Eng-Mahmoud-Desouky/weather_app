import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../authentication/presentation/cubit/auth_state.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/weather_data_entitie.dart';
import '../bloc/home_page_bloc.dart';
import '../widgets/weather_card.dart';
import '../widgets/single_day_forecast.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import '../../../ai_prediction/presentation/bloc/ai_prediction_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Currently selected date for weather display
  DateTime _selectedDate = DateTime.now();

  /// Current location for weather data
  final String _currentLocation = ApiConstants.defaultLocation;

  @override
  void initState() {
    super.initState();
    // Fetch initial weather data when the screen loads
    _fetchWeatherData();
  }

  /// Fetches weather data for the current location
  void _fetchWeatherData() {
    // Fetch both current weather and 7-day forecast
    context.read<HomePageBloc>().add(
      FetchWeatherForecast(_currentLocation, days: 7),
    );
  }

  /// Refreshes weather data
  void _refreshWeatherData() {
    // Refresh both current weather and forecast
    context.read<HomePageBloc>().add(
      FetchWeatherForecast(_currentLocation, days: 7),
    );
  }

  /// Finds weather data for the selected date from the forecast list
  WeatherData? _getWeatherForSelectedDate(List<WeatherData> forecastData) {
    // If selected date is today, return current weather (first item)
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (isToday && forecastData.isNotEmpty) {
      return forecastData.first;
    }

    // Find forecast data that matches the selected date
    for (final weather in forecastData) {
      final weatherDate = weather.lastUpdated;
      if (weatherDate.year == _selectedDate.year &&
          weatherDate.month == _selectedDate.month &&
          weatherDate.day == _selectedDate.day) {
        return weather;
      }
    }

    // Return null if no matching date is found
    return null;
  }

  /// Checks if the given date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010C2A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF010C2A), Color(0xFF39039C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return RefreshIndicator(
                  onRefresh: () async => _refreshWeatherData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with user greeting
                        _buildHeader(authState.user.name),

                        const SizedBox(height: 24),

                        // Date timeline
                        _buildDateTimeline(),

                        const SizedBox(height: 24),

                        // Weather content based on BLoC state
                        BlocBuilder<HomePageBloc, HomePageState>(
                          builder: (context, state) {
                            return _buildWeatherContent(state);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Training conditions placeholder
                        _buildTrainingConditions(),
                      ],
                    ),
                  ),
                );
              }

              // Show loading if user is not authenticated
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the header section with user greeting
  Widget _buildHeader(String userName) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello',
              style: TextStyle(
                color: Color(0xFF0847ab),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${userName.isNotEmpty ? userName : 'User'}!',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
        ),
      ],
    );
  }

  /// Builds weather content based on the current BLoC state
  Widget _buildWeatherContent(HomePageState state) {
    if (state is WeatherLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    } else if (state is CurrentWeatherLoaded) {
      // Show current weather card and single day forecast for today
      final isToday = _isToday(_selectedDate);

      return Column(
        children: [
          WeatherCard(
            weatherData: state.weatherData,
            onTap: () {
              // Refresh weather data when card is tapped
              _refreshWeatherData();
            },
          ),
          const SizedBox(height: 16),
          // Show forecast for selected date (only today's data available)
          SingleDayForecast(
            weatherData: isToday ? state.weatherData : null,
            selectedDate: _selectedDate,
          ),
          const SizedBox(height: 16),
        ],
      );
    } else if (state is WeatherForecastLoaded) {
      return Column(
        children: [
          WeatherCard(weatherData: state.currentWeather),
          const SizedBox(height: 16),
          // Display forecast for the selected date
          SingleDayForecast(
            weatherData: _getWeatherForSelectedDate(state.forecastData),
            selectedDate: _selectedDate,
          ),
        ],
      );
    } else if (state is WeatherError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading weather data',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWeatherData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0061E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      // Initial state - show placeholder
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud, size: 80, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'Weather Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading weather information...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }
  }

  /// Builds the date timeline widget
  Widget _buildDateTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Days Forecast',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF182d4a),
            borderRadius: BorderRadius.circular(20),
          ),
          child: EasyDateTimeLinePicker.itemBuilder(
            itemBuilder:
                (context, date, isSelected, isDisabled, isToday, onTap) =>
                    InkResponse(
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat.E().format(date),
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? const Color(0xFF0847ab)
                                          : Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? const Color(0xFF0847ab)
                                          : Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            itemExtent: 55,
            timelineOptions: const TimelineOptions(height: 70),
            headerOptions: const HeaderOptions(headerType: HeaderType.none),
            focusedDate: _selectedDate,
            currentDate: DateTime.now(),
            firstDate: DateTime(2024, 3, 18),
            lastDate: DateTime(2030, 3, 18),
            onDateChange: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Builds the training conditions section with AI prediction
  Widget _buildTrainingConditions() {
    return BlocBuilder<HomePageBloc, HomePageState>(
      builder: (context, homeState) {
        // Get current weather data
        WeatherData? weatherData;
        if (homeState is CurrentWeatherLoaded) {
          weatherData = homeState.weatherData;
        } else if (homeState is WeatherForecastLoaded) {
          weatherData = homeState.currentWeather;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.fitness_center, color: Colors.white70),
                  SizedBox(width: 8),
                  Text(
                    'Exercise Conditions',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // AI Prediction Display
              if (weatherData != null)
                Builder(
                  builder: (context) {
                    // Automatically trigger prediction when weather data is available
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final aiBloc = context.read<AiPredictionBloc>();
                      // Only trigger if not already loading or loaded with current data
                      if (aiBloc.state is AiPredictionInitial ||
                          aiBloc.state is AiPredictionError) {
                        aiBloc.add(PredictFromWeatherData(weatherData!));
                      }
                    });

                    return BlocBuilder<AiPredictionBloc, AiPredictionState>(
                      builder: (context, aiState) {
                        if (aiState is AiPredictionLoading) {
                          return const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Analyzing weather conditions...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        } else if (aiState is AiPredictionLoaded) {
                          final result = aiState.predictionResult;
                          final isExerciseSuitable = result.suitableForExercise;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isExerciseSuitable
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isExerciseSuitable
                                            ? Colors.green
                                            : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isExerciseSuitable
                                          ? 'Weather is suitable for exercise'
                                          : 'Weather is not suitable for exercise',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result.message,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        } else if (aiState is AiPredictionError) {
                          return const Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Unable to analyze exercise conditions',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return const Text(
                          'Tap to check exercise conditions',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        );
                      },
                    );
                  },
                )
              else
                const Text(
                  'Weather data not available',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
            ],
          ),
        );
      },
    );
  }
}
