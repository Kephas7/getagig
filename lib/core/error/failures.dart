import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable {
  final String message;
  const Failures(this.message);
  @override
  List<Object?> get props => [message];
}

class LocalDatabaseFailure extends Failures {
  const LocalDatabaseFailure({
    String message = 'Local database operations failed.',
  }) : super(message);
}

class ApiFailure extends Failures {
  final int? statusCode;
  const ApiFailure({required String message, this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failures {
  const NetworkFailure({String message = "No internet connection"})
    : super(message);
}