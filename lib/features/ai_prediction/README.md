# AI Prediction Feature

## Overview

The AI Prediction feature provides machine learning-based analysis of weather conditions to determine training suitability. It follows Clean Architecture principles and integrates seamlessly with the existing weather app.

## Architecture

The feature is organized into three layers following Clean Architecture:

### Domain Layer
- **Entities**: `PredictionResult`, `WeatherFeatures`
- **Repositories**: `AiPredictionRepository` (interface)
- **Use Cases**: `PredictTrainingSuitability`, `CheckAiServiceHealth`
- **Utils**: `WeatherFeatureConverter` (converts weather data to AI features)

### Data Layer
- **Models**: `PredictionResponseModel`, `WeatherFeaturesModel`
- **Data Sources**: `AiPredictionRemoteDataSource` (Flask API communication)
- **Repositories**: `AiPredictionRepositoryImpl` (implementation)

### Presentation Layer
- **BLoC**: `AiPredictionBloc` (state management)
- **Widgets**: `AiPredictionCard`, `AiPredictionWidget`, `AiPredictionFeature`

## Features

### Weather Feature Conversion
The system converts weather data into 5 binary features for the AI model:
1. **Outlook Rainy** (0/1) - Based on weather condition keywords
2. **Outlook Sunny** (0/1) - Based on weather condition keywords  
3. **Temperature Hot** (0/1) - Temperature > 30°C
4. **Temperature Mild** (0/1) - Temperature between 15°C and 30°C
5. **Humidity Normal** (0/1) - Humidity between 40% and 70%

### AI Model Integration
- Communicates with Flask server at `http://127.0.0.1:5000`
- Sends POST requests to `/predict` endpoint
- Handles health checks via `/health` endpoint
- Includes comprehensive error handling and timeout management

## Usage

### Basic Integration

To add AI prediction to any screen with weather data:

```dart
import 'package:weather_app/features/ai_prediction/presentation/widgets/ai_prediction_widget.dart';

// In your widget build method:
Column(
  children: [
    WeatherCard(weatherData: currentWeather),
    SizedBox(height: 16),
    AiPredictionFeature(weatherData: currentWeather),
  ],
)
```

### Home Screen Integration Example

To integrate into the existing home screen, add the AI prediction widget after the weather cards:

```dart
// In home_screen.dart, in the _buildWeatherContent method:
if (state is WeatherLoaded) {
  return Column(
    children: [
      WeatherCard(
        weatherData: state.weatherData,
        onTap: () => _refreshWeatherData(),
      ),
      const SizedBox(height: 16),
      SingleDayForecast(
        weatherData: isToday ? state.weatherData : null,
        selectedDate: _selectedDate,
      ),
      const SizedBox(height: 16),
      // Add AI Prediction Feature
      AiPredictionFeature(
        weatherData: state.weatherData,
        autoPredict: false, // User must manually trigger predictions
      ),
    ],
  );
}
```

### Manual BLoC Usage

For more control over the prediction process:

```dart
// Trigger a prediction
context.read<AiPredictionBloc>().add(
  PredictFromWeatherData(weatherData),
);

// Check service health
context.read<AiPredictionBloc>().add(
  const CheckServiceHealth(),
);

// Reset prediction state
context.read<AiPredictionBloc>().add(
  const ResetPrediction(),
);
```

## Setup Requirements

### 1. Flask AI Model Server

Start the Flask server before using the AI prediction feature:

```bash
cd ai_model_server
pip install -r requirements.txt
python app.py
```

The server will run on `http://127.0.0.1:5000`

### 2. Dependency Injection

The feature is automatically registered in the dependency injection container. No additional setup required.

### 3. Model File

Ensure the AI model file (`model.pkl`) is placed in the `ai_model_server/` directory.

## Error Handling

The feature includes comprehensive error handling:

- **Network Errors**: Connection timeouts, server unavailable
- **Server Errors**: Invalid responses, model loading failures  
- **Validation Errors**: Invalid weather feature combinations
- **Timeout Errors**: Request timeouts with configurable duration

## Testing

Run the feature tests:

```bash
flutter test test/features/ai_prediction/
```

## Configuration

### Timeouts
Default timeout is 10 seconds. Configure in `AiPredictionRemoteDataSourceImpl`:

```dart
const AiPredictionRemoteDataSourceImpl({
  required this.dio,
  this.baseUrl = 'http://127.0.0.1:5000',
  this.timeoutDuration = 10000, // 10 seconds
});
```

### Weather Feature Thresholds
Adjust thresholds in `WeatherFeatureConverter`:

```dart
static const double hotTemperatureThreshold = 30.0;
static const double mildTemperatureMinThreshold = 15.0;
static const double normalHumidityMinThreshold = 40.0;
static const double normalHumidityMaxThreshold = 70.0;
```

## API Reference

### Prediction Request
```json
POST /predict
{
  "features": [0, 1, 0, 1, 1]
}
```

### Prediction Response
```json
{
  "prediction": 1,
  "suitable_for_training": true,
  "confidence": "high",
  "message": "Suitable for training",
  "input_features": {
    "outlook_rainy": 0,
    "outlook_sunny": 1,
    "temperature_hot": 0,
    "temperature_mild": 1,
    "humidity_normal": 1
  }
}
```

### Health Check
```json
GET /health
{
  "status": "healthy",
  "model_loaded": true
}
```

## Future Enhancements

- Caching of prediction results
- Offline prediction capabilities
- Multiple AI model support
- Historical prediction tracking
- User feedback integration
- Custom threshold configuration UI
