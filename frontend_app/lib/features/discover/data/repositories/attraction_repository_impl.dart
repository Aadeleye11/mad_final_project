import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../core/error/failures.dart';
import '../../domain/entities/attraction.dart';
import '../../domain/repositories/attraction_repository.dart';
import '../datasources/attraction_local_datasource.dart';
import '../datasources/attraction_remote_datasource.dart';
import '../models/attraction_model.dart';

/// Order of preference: Firestore, then local cache, then the bundled seed
/// asset. Filtering runs in memory since the catalogue is small.
class AttractionRepositoryImpl implements AttractionRepository {
  final AttractionRemoteDataSource remote;
  final AttractionLocalDataSource local;

  AttractionRepositoryImpl({required this.remote, required this.local});

  static const String seedAssetPath = 'assets/data/attractions_seed.json';

  @override
  Future<Either<Failure, List<Attraction>>> getAttractions() async {
    try {
      final remoteList = await remote.fetchAll();
      if (remoteList.isNotEmpty) {
        await local.cache(remoteList);
        return Right(remoteList);
      }
      return Right(await _fallback());
    } catch (_) {
      // Fall back rather than fail the screen.
      try {
        return Right(await _fallback());
      } catch (_) {
        return const Left(CacheFailure());
      }
    }
  }

  /// Cache first, then the bundled asset.
  Future<List<AttractionModel>> _fallback() async {
    if (local.hasCache) {
      final cached = await local.getCached();
      if (cached.isNotEmpty) return cached;
    }
    final raw = await rootBundle.loadString(seedAssetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    final seeded = decoded
        .map((e) => AttractionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    await local.cache(seeded);
    return seeded;
  }

  @override
  Future<Either<Failure, List<Attraction>>> getByCategory(
    AttractionCategory category,
  ) async {
    final result = await getAttractions();
    return result.map(
      (all) => all.where((a) => a.category == category).toList(),
    );
  }

  @override
  Future<Either<Failure, List<Attraction>>> search(String query) async {
    final result = await getAttractions();
    final needle = query.toLowerCase();
    return result.map(
      (all) => all
          .where(
            (a) =>
                a.name.toLowerCase().contains(needle) ||
                a.district.toLowerCase().contains(needle) ||
                a.category.label.toLowerCase().contains(needle),
          )
          .toList(),
    );
  }

  @override
  Future<Either<Failure, Attraction>> getById(String id) async {
    final result = await getAttractions();
    return result.fold(Left.new, (all) {
      final match = all.where((a) => a.id == id);
      if (match.isEmpty) {
        return const Left(CacheFailure('That place is not in the catalogue.'));
      }
      return Right(match.first);
    });
  }

  @override
  Future<Either<Failure, List<Attraction>>> getByIds(List<String> ids) async {
    final result = await getAttractions();
    return result.map((all) {
      final byId = {for (final a in all) a.id: a};
      return ids.map((id) => byId[id]).whereType<Attraction>().toList();
    });
  }
}
