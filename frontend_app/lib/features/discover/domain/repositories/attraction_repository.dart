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

  /// Resolves the compact ID list decoded from a scanned QR code.
  /// Reads from the local cache only, so it works with no connectivity.
  Future<Either<Failure, List<Attraction>>> getByIds(List<String> ids);
}
