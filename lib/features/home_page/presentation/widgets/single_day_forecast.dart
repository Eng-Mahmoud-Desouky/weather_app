import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/weather_data_entitie.dart';

/// Widget that displays detailed weather forecast for a single selected day
/// This widget shows comprehensive weather information for one specific date
class SingleDayForecast extends StatelessWidget {
  /// The weather data for the selected day
  final WeatherData? weatherData;
  
  /// The selected date to display
  final DateTime selectedDate;

  const SingleDayForecast({
    super.key,
    required this.weatherData,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    // If no weather data is available for the selected date
    if (weatherData == null) {
      return _buildNoDataCard();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date
          _buildHeader(),
          
          const SizedBox(height: 20),
          
          // Main weather info
          _buildMainWeatherInfo(),
          
          const SizedBox(height: 20),
          
          // Weather details grid
          _buildWeatherDetails(),
        ],
      ),
    );
  }

  /// Builds the header section with date information
  Widget _buildHeader() {
    final dayName = DateFormat('EEEE').format(selectedDate);
    final dateString = DateFormat('d MMMM yyyy').format(selectedDate);
    final isToday = _isToday(selectedDate);
    
    return Row(
      children: [
        const Icon(
          Icons.calendar_today,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isToday ? 'Today' : dayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                dateString,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the main weather information section
  Widget _buildMainWeatherInfo() {
    return Row(
      children: [
        // Weather icon and condition
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather icon
              if (weatherData!.iconUrl.isNotEmpty)
                Image.network(
                  weatherData!.iconUrl,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.cloud,
                      size: 80,
                      color: Colors.white70,
                    );
                  },
                )
              else
                const Icon(
                  Icons.cloud,
                  size: 80,
                  color: Colors.white70,
                ),
              
              const SizedBox(height: 8),
              
              // Weather condition
              Text(
                weatherData!.condition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Temperature information
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Max temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weatherData!.temperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Temperature range
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'High: ${weatherData!.temperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Low: ${weatherData!.feelsLike.round()}°',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the weather details grid
  Widget _buildWeatherDetails() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                Icons.air,
                'Wind Speed',
                '${weatherData!.windSpeed.round()} km/h',
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                Icons.water_drop,
                'Humidity',
                '${weatherData!.humidity}%',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                Icons.speed,
                'Pressure',
                '${weatherData!.pressure.round()} mb',
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                Icons.wb_sunny,
                'UV Index',
                weatherData!.uvIndex.round().toString(),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                Icons.visibility,
                'Visibility',
                '${weatherData!.visibility.round()} km',
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                Icons.cloud,
                'Cloudiness',
                '${weatherData!.cloudiness}%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds an individual detail item
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.white70,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds a card when no data is available
  Widget _buildNoDataCard() {
    final dayName = DateFormat('EEEE').format(selectedDate);
    final dateString = DateFormat('d MMMM yyyy').format(selectedDate);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 60,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          Text(
            dayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateString,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No forecast data available for this date',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Checks if the given date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}
