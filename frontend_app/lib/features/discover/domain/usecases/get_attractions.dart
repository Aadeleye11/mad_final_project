import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attraction.dart';
import '../repositories/attraction_repository.dart';

class GetAttractions implements UseCase<List<Attraction>, NoParams> {
  final AttractionRepository repository;
  GetAttractions(this.repository);

  @override
  Future<Either<Failure, List<Attraction>>> call(NoParams params) =>
      repository.getAttractions();
}
