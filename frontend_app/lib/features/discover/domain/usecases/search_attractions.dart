import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attraction.dart';
import '../repositories/attraction_repository.dart';

class SearchAttractions implements UseCase<List<Attraction>, SearchParams> {
  final AttractionRepository repository;
  SearchAttractions(this.repository);

  @override
  Future<Either<Failure, List<Attraction>>> call(SearchParams params) {
    final query = params.query.trim();
    // An empty search isn't an error; it means "show everything".
    if (query.isEmpty) return repository.getAttractions();
    if (query.length < 2) {
      return Future.value(
        const Left(
          ValidationFailure('Type at least two characters to search.'),
        ),
      );
    }
    return repository.search(query);
  }
}

class SearchParams extends Equatable {
  final String query;
  const SearchParams(this.query);

  @override
  List<Object?> get props => [query];
}
