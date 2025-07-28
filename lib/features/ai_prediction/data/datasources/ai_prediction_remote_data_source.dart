import 'package:dio/dio.dart';
import '../models/prediction_response_model.dart';
import '../../domain/entities/prediction_result.dart';

/// Remote data source for AI prediction API communication
/// 
/// This class handles all HTTP communication with the Flask AI model server.
/// It's responsible for:
/// - Making prediction requests to the Flask API
/// - Checking service health status
/// - Handling HTTP errors and timeouts
/// - Converting between domain entities and API request/response formats
/// 
/// Following Clean Architecture, this data source is an implementation detail
/// that the domain layer doesn't know about. It communicates with external
/// services and converts the responses to domain entities.
abstract class AiPredictionRemoteDataSource {
  /// Makes a prediction request to the AI model server
  /// 
  /// Sends weather features to the Flask API and returns the prediction result.
  /// This method handles the HTTP communication and response parsing.
  /// 
  /// Parameters:
  /// - [features]: Weather features to send for prediction
  /// 
  /// Returns: PredictionResponseModel with the prediction result
  /// 
  /// Throws:
  /// - [ServerException]: If the server returns an error response
  /// - [NetworkException]: If network communication fails
  /// - [TimeoutException]: If the request times out
  Future<PredictionResponseModel> predictTrainingSuitability(
    WeatherFeatures features,
  );

  /// Checks if the AI prediction service is healthy and ready
  /// 
  /// Makes a health check request to verify that the Flask server is running
  /// and the AI model is loaded and ready to make predictions.
  /// 
  /// Returns: true if service is healthy, false if not ready
  /// 
  /// Throws:
  /// - [ServerException]: If the server returns an error response
  /// - [NetworkException]: If network communication fails
  /// - [TimeoutException]: If the request times out
  Future<bool> checkServiceHealth();
}

/// Implementation of the AI prediction remote data source
/// 
/// This class implements the actual HTTP communication with the Flask API
/// using the Dio HTTP client. It handles request formatting, response parsing,
/// error handling, and timeout management.
class AiPredictionRemoteDataSourceImpl implements AiPredictionRemoteDataSource {
  /// HTTP client for making API requests
  /// Injected through constructor for dependency inversion and testing
  final Dio dio;
  
  /// Base URL of the Flask AI model server
  /// Configurable for different environments (development, production, etc.)
  final String baseUrl;
  
  /// Timeout duration for API requests in milliseconds
  /// Prevents hanging requests if the server is slow or unresponsive
  final int timeoutDuration;

  const AiPredictionRemoteDataSourceImpl({
    required this.dio,
    this.baseUrl = 'http://127.0.0.1:5000', // Default Flask development server
    this.timeoutDuration = 10000, // 10 seconds default timeout
  });

  @override
  Future<PredictionResponseModel> predictTrainingSuitability(
    WeatherFeatures features,
  ) async {
    try {
      // Convert domain entity to API request format
      final featuresModel = WeatherFeaturesModel.fromDomain(features);
      final requestBody = featuresModel.toApiRequest();

      // Make POST request to the prediction endpoint
      final response = await dio.post(
        '$baseUrl/predict',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: Duration(milliseconds: timeoutDuration),
          receiveTimeout: Duration(milliseconds: timeoutDuration),
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Parse the response into a domain entity
        return PredictionResponseModel.fromJson(responseData);
      } else {
        // Handle non-200 status codes
        throw ServerException(
          'Prediction request failed with status ${response.statusCode}: ${response.statusMessage}'
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeout, etc.)
      throw _handleDioException(e);
    } catch (e) {
      // Handle any other unexpected errors
      throw ServerException(
        'Unexpected error during prediction: ${e.toString()}'
      );
    }
  }

  @override
  Future<bool> checkServiceHealth() async {
    try {
      // Make GET request to the health check endpoint
      final response = await dio.get(
        '$baseUrl/health',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          sendTimeout: Duration(milliseconds: timeoutDuration),
          receiveTimeout: Duration(milliseconds: timeoutDuration),
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Parse the health status from the response
        // The Flask API returns: {"status": "healthy", "model_loaded": true}
        final status = responseData['status'] as String?;
        final modelLoaded = responseData['model_loaded'] as bool?;
        
        // Service is healthy if status is "healthy" and model is loaded
        return status == 'healthy' && (modelLoaded ?? false);
      } else {
        // Non-200 status means service is not healthy
        return false;
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      throw _handleDioException(e);
    } catch (e) {
      // Handle any other unexpected errors
      throw ServerException(
        'Unexpected error during health check: ${e.toString()}'
      );
    }
  }

  /// Handles Dio exceptions and converts them to appropriate custom exceptions
  /// 
  /// This method centralizes error handling for all HTTP requests and provides
  /// meaningful error messages based on the type of network error that occurred.
  /// 
  /// Parameters:
  /// - [e]: The DioException that was thrown
  /// 
  /// Returns: An appropriate custom exception
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Request timed out. Please check your connection and try again.'
        );
        
      case DioExceptionType.connectionError:
        return NetworkException(
          'Unable to connect to AI prediction service. Please check if the server is running.'
        );
        
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? e.message;
        return ServerException(
          'Server error ($statusCode): $message'
        );
        
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled');
        
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          'Network error: ${e.message ?? "Unknown error occurred"}'
        );
    }
  }
}

/// Custom exception for server-related errors
/// 
/// Thrown when the AI prediction server returns an error response
/// or when there's an issue with the server-side processing.
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

/// Custom exception for network-related errors
/// 
/// Thrown when there are network connectivity issues, timeouts,
/// or other communication problems with the AI prediction server.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Custom exception for request timeout errors
/// 
/// Thrown when API requests take longer than the configured timeout duration.
/// This helps distinguish timeout errors from other network issues.
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}
