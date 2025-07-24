import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/weather_data_entitie.dart';

/// Widget that displays a 7-day weather forecast
/// This widget shows forecast data in a clean, consistent design
/// that matches the existing UI styling
class ForecastCard extends StatelessWidget {
  /// List of weather forecast data for multiple days
  final List<WeatherData> forecastData;

  const ForecastCard({
    super.key,
    required this.forecastData,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header
          const Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white70,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '7-Day Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Forecast list
          ...forecastData.take(7).map((weather) => _buildForecastItem(weather)),
        ],
      ),
    );
  }

  /// Builds an individual forecast item for one day
  Widget _buildForecastItem(WeatherData weather) {
    // Parse the date from lastUpdated to get the forecast date
    final date = weather.lastUpdated;
    final dayName = DateFormat('EEEE').format(date); // Full day name
    final dateString = DateFormat('d MMMM').format(date); // Day and month
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Date column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateString,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Weather icon and condition
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Weather icon
                if (weather.iconUrl.isNotEmpty)
                  Image.network(
                    weather.iconUrl,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.cloud,
                        size: 32,
                        color: Colors.white70,
                      );
                    },
                  )
                else
                  const Icon(
                    Icons.cloud,
                    size: 32,
                    color: Colors.white70,
                  ),
                
                const SizedBox(width: 8),
                
                // Weather condition
                Expanded(
                  child: Text(
                    weather.condition,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Temperature range
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Max temperature (using the main temperature as max)
                Text(
                  '${weather.temperature.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                // Min temperature (using feels like as approximation)
                Text(
                  '${weather.feelsLike.round()}°',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
