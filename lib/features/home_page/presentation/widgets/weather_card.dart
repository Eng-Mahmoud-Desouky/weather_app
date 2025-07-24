import 'package:flutter/material.dart';
import '../../domain/entities/weather_data_entitie.dart';

/// Widget that displays current weather information in a card format
/// This is a reusable component that shows the main weather details
class WeatherCard extends StatelessWidget {
  /// The weather data to display
  final WeatherData weatherData;
  
  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  const WeatherCard({
    super.key,
    required this.weatherData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and weather icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherData.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weatherData.condition,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Weather icon
                if (weatherData.iconUrl.isNotEmpty)
                  Image.network(
                    weatherData.iconUrl,
                    width: 64,
                    height: 64,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.cloud,
                        size: 64,
                        color: Colors.white70,
                      );
                    },
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Temperature display
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weatherData.temperature.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Feels like ${weatherData.feelsLike.round()}°',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Weather details grid
            Row(
              children: [
                Expanded(
                  child: _WeatherDetailItem(
                    icon: Icons.air,
                    label: 'Wind',
                    value: '${weatherData.windSpeed.round()} km/h',
                  ),
                ),
                Expanded(
                  child: _WeatherDetailItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${weatherData.humidity}%',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _WeatherDetailItem(
                    icon: Icons.speed,
                    label: 'Pressure',
                    value: '${weatherData.pressure.round()} mb',
                  ),
                ),
                Expanded(
                  child: _WeatherDetailItem(
                    icon: Icons.wb_sunny,
                    label: 'UV Index',
                    value: weatherData.uvIndex.round().toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal widget for displaying individual weather detail items
class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
