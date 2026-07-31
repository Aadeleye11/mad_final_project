import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attraction_model.dart';

abstract class AttractionRemoteDataSource {
  Future<List<AttractionModel>> fetchAll();
}

class AttractionRemoteDataSourceImpl implements AttractionRemoteDataSource {
  /// Optional so tests can inject a fake instance. Left null in the app, the
  /// real handle is resolved lazily inside [fetchAll] — that way the app still
  /// starts (and falls back to the cache) if Firebase has not been configured.
  final FirebaseFirestore? _injected;

  AttractionRemoteDataSourceImpl([this._injected]);

  static const String collectionPath = 'attractions';

  FirebaseFirestore get _db => _injected ?? FirebaseFirestore.instance;

  @override
  Future<List<AttractionModel>> fetchAll() async {
    final snapshot = await _db.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => AttractionModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
