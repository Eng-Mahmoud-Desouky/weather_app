import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Abstract base class for all use cases in the application
/// 
/// This class defines the contract that all use cases must follow,
/// ensuring consistency across the application and making it easier
/// to test and maintain business logic.
/// 
/// Type Parameters:
/// - [Type]: The return type of the use case
/// - [Params]: The parameter type that the use case accepts
/// 
/// Following Clean Architecture principles, use cases:
/// - Contain application-specific business rules
/// - Are independent of external frameworks
/// - Orchestrate the flow of data to and from entities
/// - Can be easily tested in isolation
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters
  /// 
  /// Returns an [Either] type where:
  /// - [Left] contains a [Failure] if something went wrong
  /// - [Right] contains the successful result of type [Type]
  /// 
  /// This pattern allows for explicit error handling and makes
  /// the code more predictable and easier to test.
  Future<Either<Failure, Type>> call(Params params);
}

/// Parameter class for use cases that don't require any parameters
/// 
/// This class serves as a placeholder for use cases that don't need
/// input parameters, maintaining consistency with the UseCase interface
/// while clearly indicating that no parameters are required.
/// 
/// Example usage:
/// ```dart
/// class GetCurrentWeather implements UseCase<WeatherData, NoParams> {
///   @override
///   Future<Either<Failure, WeatherData>> call(NoParams params) async {
///     // Implementation that doesn't need parameters
///   }
/// }
/// ```
class NoParams {
  const NoParams();
  
  @override
  bool operator ==(Object other) => other is NoParams;
  
  @override
  int get hashCode => 0;
  
  @override
  String toString() => 'NoParams()';
}
