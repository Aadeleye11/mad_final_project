import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attraction.dart';

abstract class AttractionRepository {
  /// Remote when online, local cache when not. Never throws.
  Future<Either<Failure, List<Attraction>>> getAttractions();

  Future<Either<Failure, List<Attraction>>> getByCategory(
    AttractionCategory category,
  );

  Future<Either<Failure, List<Attraction>>> search(String query);

  Future<Either<Failure, Attraction>> getById(String id);

  /// For a scanned QR code's ID list. Reads the local cache only.
  Future<Either<Failure, List<Attraction>>> getByIds(List<String> ids);
}
