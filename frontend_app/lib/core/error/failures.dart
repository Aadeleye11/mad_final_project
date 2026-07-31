import 'package:equatable/equatable.dart';

/// Repositories return `Either<Failure, T>`, so callers never catch raw exceptions.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Could not reach the server.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No saved places available offline.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
