import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attraction_model.dart';

/// SharedPreferences over Hive on purpose: no codegen, no build_runner step.
abstract class AttractionLocalDataSource {
  Future<List<AttractionModel>> getCached();
  Future<void> cache(List<AttractionModel> attractions);
  bool get hasCache;
}

class AttractionLocalDataSourceImpl implements AttractionLocalDataSource {
  final SharedPreferences prefs;
  AttractionLocalDataSourceImpl(this.prefs);

  static const String cacheKey = 'cached_attractions';

  @override
  bool get hasCache => prefs.containsKey(cacheKey);

  @override
  Future<List<AttractionModel>> getCached() async {
    final raw = prefs.getString(cacheKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => AttractionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cache(List<AttractionModel> attractions) async {
    final encoded = jsonEncode(attractions.map((a) => a.toJson()).toList());
    await prefs.setString(cacheKey, encoded);
  }
}
