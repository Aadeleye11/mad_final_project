import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attraction_model.dart';

abstract class AttractionRemoteDataSource {
  Future<List<AttractionModel>> fetchAll();
}

class AttractionRemoteDataSourceImpl implements AttractionRemoteDataSource {
  /// Optional so tests can inject a fake; resolved lazily so the app still
  /// starts if Firebase isn't configured yet.
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
