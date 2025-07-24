import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the application
/// This follows the Clean Architecture principle of having
/// domain-specific error types that are independent of external frameworks
abstract class Failure extends Equatable {
  /// Error message describing what went wrong
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Failure that occurs when there's no internet connection
/// or network-related issues
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure that occurs when the server returns an error
/// (4xx, 5xx HTTP status codes)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure that occurs when data parsing fails
/// (malformed JSON, unexpected data structure)
class DataParsingFailure extends Failure {
  const DataParsingFailure(super.message);
}

/// Failure that occurs when the requested location is not found
class LocationNotFoundFailure extends Failure {
  const LocationNotFoundFailure(super.message);
}

/// Failure that occurs when API key is invalid or quota exceeded
class ApiKeyFailure extends Failure {
  const ApiKeyFailure(super.message);
}

/// Generic failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
