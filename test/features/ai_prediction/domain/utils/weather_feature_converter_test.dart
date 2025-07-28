import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/features/ai_prediction/domain/utils/weather_feature_converter.dart';
import 'package:weather_app/features/home_page/domain/entities/weather_data_entitie.dart';

void main() {
  group('WeatherFeatureConverter', () {
    test('should convert sunny and mild weather correctly', () {
      // Arrange
      final weatherData = WeatherData(
        location: 'Test City',
        temperature: 22.0,
        condition: 'Sunny',
        iconUrl: 'test_icon.png',
        windSpeed: 10.0,
        humidity: 55,
        pressure: 1013.0,
        uvIndex: 5.0,
        cloudiness: 10,
        feelsLike: 24.0,
        visibility: 10.0,
        lastUpdated: DateTime.now(),
      );

      // Act
      final features = WeatherFeatureConverter.convertWeatherData(weatherData);

      // Assert
      expect(features.outlookRainy, false);
      expect(features.outlookSunny, true);
      expect(features.temperatureHot, false);
      expect(features.temperatureMild, true);
      expect(features.humidityNormal, true);
    });

    test('should convert rainy and hot weather correctly', () {
      // Arrange
      final weatherData = WeatherData(
        location: 'Test City',
        temperature: 35.0,
        condition: 'Heavy rain',
        iconUrl: 'test_icon.png',
        windSpeed: 15.0,
        humidity: 85,
        pressure: 1008.0,
        uvIndex: 2.0,
        cloudiness: 90,
        feelsLike: 38.0,
        visibility: 5.0,
        lastUpdated: DateTime.now(),
      );

      // Act
      final features = WeatherFeatureConverter.convertWeatherData(weatherData);

      // Assert
      expect(features.outlookRainy, true);
      expect(features.outlookSunny, false);
      expect(features.temperatureHot, true);
      expect(features.temperatureMild, false);
      expect(features.humidityNormal, false);
    });

    test('should convert cold and cloudy weather correctly', () {
      // Arrange
      final weatherData = WeatherData(
        location: 'Test City',
        temperature: 5.0,
        condition: 'Cloudy',
        iconUrl: 'test_icon.png',
        windSpeed: 8.0,
        humidity: 30,
        pressure: 1020.0,
        uvIndex: 1.0,
        cloudiness: 80,
        feelsLike: 2.0,
        visibility: 15.0,
        lastUpdated: DateTime.now(),
      );

      // Act
      final features = WeatherFeatureConverter.convertWeatherData(weatherData);

      // Assert
      expect(features.outlookRainy, false);
      expect(features.outlookSunny, false);
      expect(features.temperatureHot, false);
      expect(features.temperatureMild, false);
      expect(features.humidityNormal, false);
    });

    test('should generate correct binary list', () {
      // Arrange
      final weatherData = WeatherData(
        location: 'Test City',
        temperature: 25.0,
        condition: 'Partly sunny',
        iconUrl: 'test_icon.png',
        windSpeed: 12.0,
        humidity: 60,
        pressure: 1015.0,
        uvIndex: 6.0,
        cloudiness: 40,
        feelsLike: 27.0,
        visibility: 12.0,
        lastUpdated: DateTime.now(),
      );

      // Act
      final features = WeatherFeatureConverter.convertWeatherData(weatherData);
      final binaryList = features.toBinaryList();

      // Assert
      expect(binaryList, [
        0,
        1,
        0,
        1,
        1,
      ]); // [rainy, sunny, hot, mild, normal_humidity]
    });

    test('should provide meaningful conversion explanation', () {
      // Arrange
      final weatherData = WeatherData(
        location: 'Test City',
        temperature: 28.0,
        condition: 'Clear sky',
        iconUrl: 'test_icon.png',
        windSpeed: 5.0,
        humidity: 45,
        pressure: 1018.0,
        uvIndex: 8.0,
        cloudiness: 5,
        feelsLike: 30.0,
        visibility: 20.0,
        lastUpdated: DateTime.now(),
      );

      // Act
      final features = WeatherFeatureConverter.convertWeatherData(weatherData);
      final explanation = WeatherFeatureConverter.getConversionExplanation(
        weatherData,
        features,
      );

      // Assert
      expect(explanation, isNotEmpty);
      expect(explanation, contains('Clear sky'));
      expect(explanation, contains('28.0°C'));
      expect(explanation, contains('45%'));
    });
  });
}
